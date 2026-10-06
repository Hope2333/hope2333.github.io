#!/usr/bin/env bash
set -euo pipefail
# linkcheck.sh — 全站死链扫描 + lang-map 双向一致性检查（离线，零外部请求）
#
# 1) 以 CI 同参数完整构建 _site（tools/render-one.sh --all + tools/gen-redirects.sh，防双源漂移）
# 2) 扫描全部生成 html（_site/**/*.html 与仓根手写 index.html）与仓内 md 的站内链接
#    （相对 + 站内绝对），对文件型目标断言存在；存在性按 仓内源 ∪ _site 产物 判定
#    （CI 的 Assemble step 会把整仓拷入 _site，故源存在 ⇔ 终态 _site 存在）。
# 3) lang-map 双向一致性（正向 en canonical 全量 + status=full 页 zh_CN；反向登记防漏）。
# node 仅作扫描器运行时，不构成构建系统。

cd "$(dirname "$0")/.."

# ── 1. 完整构建 ──────────────────────────────────────────────────────────
bash tools/render-one.sh --all
bash tools/gen-redirects.sh

# ── 2. 死链扫描 ──────────────────────────────────────────────────────────
node --input-type=module <<'SCAN'
import fs from 'node:fs';
import path from 'node:path';

const REPO = process.cwd();
const SITE = path.join(REPO, '_site');

function walk(dir, ext, out = []) {
  let ents;
  try { ents = fs.readdirSync(dir, { withFileTypes: true }); } catch { return out; }
  for (const e of ents) {
    const f = path.join(dir, e.name);
    if (e.isDirectory()) {
      // 跳过规划工件与本地残留：非站点内容（.omo 计划/证据里的示例链接不算死链）
      if (['.git', '.omo', 'build', '_site', 'node_modules'].includes(e.name)) continue;
      walk(f, ext, out);
    } else if (e.isFile() && e.name.endsWith(ext)) out.push(f);
  }
  return out;
}

function targetExists(rel) {
  // rel: 无前导斜杠、去 fragment/query 的仓库相对目标
  if (rel === '' || rel === '.') rel = 'index.html';
  for (const base of [SITE, REPO]) {
    const f = path.join(base, rel);
    try { if (fs.statSync(f).isFile()) return true; } catch { /* next */ }
    try {
      if (fs.statSync(f).isDirectory() &&
          (fs.existsSync(path.join(f, 'index.html')) || fs.existsSync(path.join(f, 'index.md')))) return true;
    } catch { /* next */ }
  }
  return false;
}

function normalize(u, baseDir) {
  let t = u.split('#')[0].split('?')[0];
  if (!t) return null; // 纯锚点
  if (/^(https?:)?\/\//i.test(t) || /^(mailto:|tel:|data:|javascript:)/i.test(t)) return null; // 外部/协议
  let rel;
  if (t.startsWith('/')) rel = t.slice(1);
  else rel = path.posix.normalize(path.posix.join(baseDir, t));
  if (rel.startsWith('..')) return 'ESCAPE:' + rel; // 越出站点根
  return rel;
}

const broken = [];
// html: _site 全量 + 仓根手写 index.html（CI 下亦会以 _site/index.html 被扫到，重复无害）
const htmls = [...walk(SITE, '.html'), path.join(REPO, 'index.html')];
for (const f of htmls) {
  let text;
  try { text = fs.readFileSync(f, 'utf8'); } catch { continue; }
  const baseDir = path.relative(SITE, path.dirname(f)).split(path.sep).join('/');
  for (const m of text.matchAll(/(?:href|src)="([^"]*)"/g)) {
    const rel = normalize(m[1], baseDir === '..' ? '' : baseDir);
    if (rel === null) continue;
    if (typeof rel === 'string' && rel.startsWith('ESCAPE:')) { broken.push(`${f} -> ${m[1]} (escapes site root)`); continue; }
    if (!targetExists(rel)) broken.push(`${f} -> ${m[1]}`);
  }
}
// md: 仓内全部（链接指向源布局；.md 相对互链与站内绝对路径）
const mds = walk(REPO, '.md').filter(f => !f.includes(`${path.sep}node_modules${path.sep}`));
for (const f of mds) {
  const text = fs.readFileSync(f, 'utf8');
  const baseDir = path.relative(REPO, path.dirname(f)).split(path.sep).join('/');
  for (const m of text.matchAll(/\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g)) {
    const rel = normalize(m[1], baseDir);
    if (rel === null) continue;
    if (typeof rel === 'string' && rel.startsWith('ESCAPE:')) { broken.push(`${f} -> ${m[1]} (escapes site root)`); continue; }
    if (!targetExists(rel)) broken.push(`${f} -> ${m[1]}`);
  }
}
if (broken.length) {
  console.error(broken.join('\n'));
  console.error(`broken=${broken.length}`);
  process.exit(1);
}
console.log(`broken=0 (html scanned: ${htmls.length}, md scanned: ${mds.length})`);
SCAN

# ── 3. lang-map 正向一致性（en canonical 全量 + status=full 页 zh_CN；用户裁决 r6 口径）──
! jq -r '.[] | .alternates.en, (select(.status=="full") | .alternates.zh_CN)' wiki/tpl/lang-map.json | while read -r u; do u="${u#/}"; test -f "$u.md" || echo "missing: $u.md"; done | grep -q 'missing:'

# ── 4. lang-map 反向登记（防新页漏登记；en 即根 wiki/ 与 en/ 同 key；es 一并纳入）──
! find wiki en zh_CN zh_TW ja es -name '*.md' | sed -E 's#^(en|zh_CN|zh_TW|ja|es)/##; s#\.md$##' | sort -u | while read -r k; do jq -e --arg k "$k" 'has($k)' wiki/tpl/lang-map.json | grep -q true || echo "unregistered: $k"; done | grep -q 'unregistered:'

echo "linkcheck: OK"
