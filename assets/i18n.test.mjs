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
      return { type: '', textContent: '', attrs: {},
        addEventListener() {},
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
