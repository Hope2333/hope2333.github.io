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
