/*
 * i18n.js — 站点语言检测 / 显式记忆 / 语言路由
 *
 * 纯函数核心（DOM 无关，node:test 可直接加载）：
 *   pickLang(browserLangs, storedLang)  语言协商：显式选择 > 浏览器语言 > en
 *   setLang(lang, storage)              校验并持久化显式选择（localStorage key: site-lang）
 *   pathForLang(logicalPath, lang)      逻辑路径 → 语言前缀 URL（en 即根 canonical）
 *
 * 浏览器侧：暴露 window.I18n，并按需自协商（见底部 DOM 挂钩）。
 * 不引入任何依赖与构建步骤；不改 theme.js 的主题/折叠逻辑。
 */
(function (global) {
  'use strict';

  var SUPPORTED_LANGS = ['en', 'zh_CN', 'zh_TW', 'ja', 'es'];
  var STORAGE_KEY = 'site-lang';

  // 单个 BCP47 tag → 站内语言。zh-TW/zh-Hant* → zh_TW；其余 zh* → zh_CN；
  // ja* → ja；es* → es；en* → en；不可映射（fr/de/…）返回 null，交由
  // pickLang 跳过后继续协商，整体兜底 en。
  function mapTag(tag) {
    if (tag === null || tag === undefined) return null;
    var t = String(tag).toLowerCase().replace(/_/g, '-');
    if (!t) return null;
    if (t === 'zh-tw' || t === 'zh-hant' || t.indexOf('zh-hant-') === 0) return 'zh_TW';
    if (t === 'zh' || t.indexOf('zh-') === 0) return 'zh_CN';
    if (t === 'ja' || t.indexOf('ja-') === 0) return 'ja';
    if (t === 'es' || t.indexOf('es-') === 0) return 'es';
    if (t === 'en' || t.indexOf('en-') === 0) return 'en';
    return null;
  }

  // browserLangs: 字符串或数组（navigator.languages 形态）
  // storedLang:   localStorage 里的显式选择（可为 null/undefined）
  // 规则：显式有效选择压过浏览器语言（A5）；否则取第一个可映射的浏览器语言；兜底 en。
  function pickLang(browserLangs, storedLang) {
    if (storedLang && SUPPORTED_LANGS.indexOf(storedLang) !== -1) {
      return storedLang;
    }
    var tags = Array.isArray(browserLangs) ? browserLangs : [browserLangs];
    for (var i = 0; i < tags.length; i++) {
      var mapped = mapTag(tags[i]);
      if (mapped) return mapped;
    }
    return 'en';
  }

  // 校验并写入选定语言。storage 可注入以便测试；缺省用 localStorage（存在时）。
  function setLang(lang, storage) {
    if (SUPPORTED_LANGS.indexOf(lang) === -1) return false;
    var s = storage;
    if (!s && typeof global.localStorage !== 'undefined') s = global.localStorage;
    if (!s) return false;
    try {
      s.setItem(STORAGE_KEY, lang);
    } catch (e) {
      return false;
    }
    return true;
  }

  // 逻辑路径（不含 LANG 前缀，如 "wiki/opencode-termux/release/Push261005"）→ URL。
  // en 指根 canonical；其余指 /<LANG>/...。
  function pathForLang(logicalPath, lang) {
    var p = String(logicalPath).replace(/^\/+/, '');
    if (lang === 'en') return '/' + p;
    return '/' + lang + '/' + p;
  }

  // 读显式选择（浏览器辅助；storage 可注入）。
  function getStoredLang(storage) {
    var s = storage;
    if (!s && typeof global.localStorage !== 'undefined') s = global.localStorage;
    if (!s) return null;
    try {
      return s.getItem(STORAGE_KEY);
    } catch (e) {
      return null;
    }
  }

  var api = {
    SUPPORTED_LANGS: SUPPORTED_LANGS,
    STORAGE_KEY: STORAGE_KEY,
    mapTag: mapTag,
    pickLang: pickLang,
    setLang: setLang,
    pathForLang: pathForLang,
    getStoredLang: getStoredLang
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;
  } else {
    global.I18n = api;
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);
