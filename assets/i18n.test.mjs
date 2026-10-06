import { createRequire } from 'node:module';
import { test } from 'node:test';
import assert from 'node:assert/strict';

const require = createRequire(import.meta.url);
const i18n = require('./i18n.js');

test('pickLang: ja → ja', () => {
  assert.equal(i18n.pickLang('ja'), 'ja');
  assert.equal(i18n.pickLang('ja-JP'), 'ja');
});

test('pickLang: zh-TW / zh-Hant → zh_TW', () => {
  assert.equal(i18n.pickLang('zh-TW'), 'zh_TW');
  assert.equal(i18n.pickLang('zh-Hant'), 'zh_TW');
  assert.equal(i18n.pickLang('zh-Hant-TW'), 'zh_TW');
});

test('pickLang: 其余 zh* → zh_CN', () => {
  assert.equal(i18n.pickLang('zh-CN'), 'zh_CN');
  assert.equal(i18n.pickLang('zh'), 'zh_CN');
  assert.equal(i18n.pickLang('zh-Hans'), 'zh_CN');
});

test('pickLang: es* → es', () => {
  assert.equal(i18n.pickLang('es'), 'es');
  assert.equal(i18n.pickLang('es-MX'), 'es');
});

test('pickLang: 其余语言 → en', () => {
  assert.equal(i18n.pickLang('fr'), 'en');
  assert.equal(i18n.pickLang('de-DE'), 'en');
  assert.equal(i18n.pickLang(undefined), 'en');
  assert.equal(i18n.pickLang([]), 'en');
});

test('pickLang: navigator.languages 数组按优先序取第一个可映射语言', () => {
  assert.equal(i18n.pickLang(['en-US', 'zh-CN']), 'en');
  assert.equal(i18n.pickLang(['fr-FR', 'ja-JP', 'en']), 'ja');
});

test('pickLang: localStorage 显式选择压过浏览器语言（A5）', () => {
  assert.equal(i18n.pickLang(['ja'], 'zh_TW'), 'zh_TW');
  assert.equal(i18n.pickLang(['zh-CN'], 'es'), 'es');
  assert.equal(i18n.pickLang(['ja'], 'en'), 'en');
});

test('pickLang: 非法显式选择被忽略，回落浏览器语言', () => {
  assert.equal(i18n.pickLang(['ja'], 'klingon'), 'ja');
  assert.equal(i18n.pickLang(['ja'], null), 'ja');
});

function fakeStorage() {
  const m = new Map();
  return {
    setItem: (k, v) => m.set(k, String(v)),
    getItem: (k) => (m.has(k) ? m.get(k) : null),
  };
}

test('setLang: 合法语言写入并可通过 getStoredLang 读回', () => {
  const s = fakeStorage();
  assert.equal(i18n.setLang('ja', s), true);
  assert.equal(i18n.getStoredLang(s), 'ja');
  assert.equal(i18n.setLang('zh_TW', s), true);
  assert.equal(i18n.getStoredLang(s), 'zh_TW');
});

test('setLang: 非法语言拒绝写入', () => {
  const s = fakeStorage();
  assert.equal(i18n.setLang('klingon', s), false);
  assert.equal(i18n.getStoredLang(s), null);
});

test('pathForLang: en 指根 canonical，其余指 /<LANG>/ 前缀', () => {
  assert.equal(i18n.pathForLang('wiki/opencode-termux/release/Push261005', 'en'),
    '/wiki/opencode-termux/release/Push261005');
  assert.equal(i18n.pathForLang('wiki/opencode-termux/release/Push261005', 'zh_CN'),
    '/zh_CN/wiki/opencode-termux/release/Push261005');
  assert.equal(i18n.pathForLang('wiki/opencode-termux/index', 'ja'),
    '/ja/wiki/opencode-termux/index');
  assert.equal(i18n.pathForLang('/wiki/index', 'es'), '/es/wiki/index');
});

test('logicalPathFromUrl: 剥 LANG 前缀与 .html 后缀，得 lang-map 键口径', () => {
  assert.equal(i18n.logicalPathFromUrl('/zh_CN/wiki/opencode-termux/index.html'),
    'wiki/opencode-termux/index');
  assert.equal(i18n.logicalPathFromUrl('/wiki/opencode-termux/release/index.html'),
    'wiki/opencode-termux/release/index');
  assert.equal(i18n.logicalPathFromUrl('/en/wiki/index.html'), 'wiki/index');
  assert.equal(i18n.logicalPathFromUrl('/ja/wiki/index'), 'wiki/index');
});

// ── 首页折叠菜单（🌐）的最小 DOM 断言 ──────────────────────────────────────
function fakeMenuDoc() {
  const items = [];
  const menu = {
    childElementCount: 0,
    textContent: '',
    appendChild(c) { items.push(c); menu.childElementCount = items.length; },
  };
  const doc = {
    createElement() {
      return { type: '', textContent: '', attrs: {}, clickHandler: null,
        addEventListener(type, fn) { if (type === 'click') this.clickHandler = fn; },
        setAttribute(k, v) { this.attrs[k] = v; } };
    },
  };
  return { doc, menu, items };
}

test('buildMenu: 展开后菜单项数=5 且当前语言 aria-current 高亮', () => {
  const { doc, menu, items } = fakeMenuDoc();
  assert.equal(i18n.buildMenu(doc, menu, 'wiki/index', 'zh_CN', () => {}, null), true);
  assert.equal(menu.childElementCount, 5);
  const cur = items.filter((it) => it.attrs['aria-current'] === 'true');
  assert.equal(cur.length, 1);
  assert.equal(cur[0].textContent, '简体中文');
});

test('buildMenu: 移除菜单容器 → 断言红（返回 false）', () => {
  const { doc } = fakeMenuDoc();
  assert.equal(i18n.buildMenu(doc, null, 'wiki/index', 'en', () => {}, null), false);
});

test('initLangMenu: 缺按钮/菜单容器 → 不接线（返回 false）', () => {
  assert.equal(i18n.initLangMenu({ getElementById: () => null }), false);
});

// ── Bug A 回归：🌐 菜单 URL 必须站点绝对（子目录页相对解析会双前缀 404）────

test('menuUrlFor: 子目录页生成站点绝对路径且无重复 LANG 前缀', () => {
  assert.equal(i18n.menuUrlFor({alternates:{ja:'ja/wiki/guides/install'}}, 'wiki/guides/install', 'ja'),
    '/ja/wiki/guides/install.html');
  assert.equal(i18n.menuUrlFor({alternates:{zh_CN:'zh_CN/wiki/guides/install'}}, 'wiki/guides/install', 'zh_CN'),
    '/zh_CN/wiki/guides/install.html');
  assert.equal(i18n.menuUrlFor(null, 'wiki/index', 'en'), '/wiki/index.html'); // pathForLang 回退同为绝对
});

test('buildMenu: 模拟点击日本語条目 → onPick 收到站点绝对 URL', () => {
  const { doc, menu, items } = fakeMenuDoc();
  const picked = [];
  const map = { 'wiki/guides/install': { alternates: { ja: 'ja/wiki/guides/install' } } };
  assert.equal(i18n.buildMenu(doc, menu, 'wiki/guides/install', 'zh_CN', (l, u) => picked.push([l, u]), map), true);
  assert.equal(items.length, 5);
  const ja = items.find((it) => it.textContent === '日本語');
  ja.clickHandler();
  assert.equal(picked.length, 1);
  assert.equal(picked[0][0], 'ja');
  assert.ok(picked[0][1].startsWith('/'), 'URL 必须以 / 开头');
  assert.equal(picked[0][1], '/ja/wiki/guides/install.html');
});
