#!/usr/bin/env bash
set -euo pipefail
# verify-site-structure.sh — CI 部署前产物结构验证（部署前门）。
# 在 site.yml 中挂于「Upload Pages artifact」之前（此时 pacman db 已由
# Build pacman repo step 生成进 _site）。本地复跑时断言④的 hope2333.db
# 无本地产物源（该 db 由 CI 内 docker repo-add 生成、不入库），如实报红。
#
# 五段断言：
#   ① 五语各自 _site/<LANG>/wiki/opencode-termux/index.html 存在（html，非裸 md）
#   ② 抽样 html lang 属性与目录语言一致
#   ③ 跳转页含 refresh 且逐行对账 redirects.tsv
#   ④ repo/ 结构：install.sh + pacman db（pacman 兜底链核心）
#   ⑤ lang-map 双向一致性（同 linkcheck.sh 口径）

cd "$(dirname "$0")/.."

fail() { echo "VERIFY FAIL: $1" >&2; exit 1; }

# ── ① 五语 index.html 存在（必须是 .html；.md 源并存属 A3 设计，不算数）──
echo "[1/5] 五语 index.html（.html）存在性"
for l in en zh_CN zh_TW ja es; do
  f="_site/$l/wiki/opencode-termux/index.html"
    [ -f "$f" ] || fail "① $f 不存在（只落裸 md 未渲染的系统性假绿）"
done

# ── ② 抽样 html lang 属性与目录语言一致 ─────────────────────────────────
echo "[2/5] html lang 属性抽样"
check_lang() { grep -q "<html lang=\"$2\"" "$1" || fail "② $1 的 html lang != $2"; }
check_lang _site/wiki/opencode-termux/index.html        en
check_lang _site/en/wiki/opencode-termux/index.html     en
check_lang _site/zh_CN/wiki/opencode-termux/index.html  zh-CN
check_lang _site/zh_TW/wiki/opencode-termux/index.html  zh-TW
check_lang _site/ja/wiki/opencode-termux/index.html     ja
check_lang _site/es/wiki/opencode-termux/index.html     es

# ── ③ 跳转页：refresh 属性 + url 指向登记新路径（全量 1:1 对账）─────────
echo "[3/5] 跳转页 refresh 对账"
n=$(jq '[.[]|select(.alternates.zh_CN!=null)]|length' wiki/tpl/lang-map.json)
[ "$(cut -f1 _site/redirects.tsv | sort -u | wc -l)" -eq "$n" ] || fail "③ redirects.tsv 去重行数 != lang-map zh_CN 登记数 ($n)"
bad=0
while read -r old new; do
  h="_site/$old"
  if [ ! -f "$h" ] || ! grep -q 'http-equiv="refresh"' "$h" || ! grep -qF "url=$new" "$h"; then
    echo "  bad: $old" >&2; bad=1
  fi
done < _site/redirects.tsv
[ "$bad" -eq 0 ] || fail "③ 存在对账失败行"

# ── ④ repo/ 结构未变：install.sh + pacman db（兜底链核心）───────────────
echo "[4/5] repo/ 结构"
[ -f _site/repo/install.sh ] || fail "④ _site/repo/install.sh 缺失"
[ -f _site/repo/Termux/pacman/hope2333.db ] || fail "④ _site/repo/Termux/pacman/hope2333.db 缺失（pacman 兜底链核心；CI 由 Build pacman repo step 生成）"

# ── ⑤ lang-map 双向一致性（同 linkcheck.sh 口径）────────────────────────
echo "[5/5] lang-map 双向一致性"
if jq -r '.[] | .alternates.en, (select(.status=="full") | .alternates.zh_CN)' wiki/tpl/lang-map.json | while read -r u; do u="${u#/}"; test -f "$u.md" || echo "missing: $u.md"; done | grep -q 'missing:'; then
  fail "⑤ 正向一致性：lang-map 登记指向不存在的源"
fi
if find wiki en zh_CN zh_TW ja es -name '*.md' | sed -E 's#^(en|zh_CN|zh_TW|ja|es)/##; s#\.md$##' | sort -u | while read -r k; do jq -e --arg k "$k" 'has($k)' wiki/tpl/lang-map.json | grep -q true || echo "unregistered: $k"; done | grep -q 'unregistered:'; then
  fail "⑤ 反向登记：存在未登记页面"
fi

echo "verify-site-structure: OK"
