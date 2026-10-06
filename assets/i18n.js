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

  // URL 路径 → 页面逻辑路径（lang-map 键口径）：剥 LANG 前缀与 .html/.htm 后缀。
  // 例：/zh_CN/wiki/opencode-termux/index.html → wiki/opencode-termux/index；
  //     /wiki/opencode-termux/release/index.html → wiki/opencode-termux/release/index（en 根 canonical 无前缀）。
  function logicalPathFromUrl(pathname) {
    var p = String(pathname || '').replace(/^\/+/, '').replace(/\.html?$/i, '');
    var segs = p.split('/');
    if (segs.length && SUPPORTED_LANGS.indexOf(segs[0]) !== -1) segs.shift();
    return segs.join('/');
  }

  var LANG_LABELS = { en: 'English', zh_CN: '简体中文', zh_TW: '繁體中文', ja: '日本語', es: 'Español' };
  var LANG_MAP_URL = '/wiki/tpl/lang-map.json';

  // 菜单构建：五语条目 + 当前语言高亮（aria-current）。
  // langMap 传入 wiki/tpl/lang-map.json 的解析结果；不可用时回落 pathForLang（与表同构）。
  function buildMenu(doc, menu, logicalPath, currentLang, onPick, langMap) {
    if (!menu) return false;
    menu.textContent = '';
    var entry = (langMap && langMap[logicalPath]) || null;
    SUPPORTED_LANGS.forEach(function (lang) {
      var url = (entry && entry.alternates && entry.alternates[lang]) || pathForLang(logicalPath, lang);
      if (url && url.charAt(0) !== '/') url = '/' + url; // 站内绝对化
      if (/\.html?$/.test(url) === false) url = url + '.html';
      var item = doc.createElement('button');
      item.type = 'button';
      item.setAttribute('aria-current', lang === currentLang ? 'true' : 'false');
      item.textContent = LANG_LABELS[lang] || lang;
      item.addEventListener('click', function () {
        onPick(lang, url);
      });
      menu.appendChild(item);
    });
    return true;
  }

  // 浏览器侧接线（DOM 相关；node 下无 document 自动跳过）：
  // 点击 🌐 弹菜单；条目点击经 setLang 写 localStorage 并跳到 lang-map 对应 URL。
  function initLangMenu(doc) {
    if (!doc || !doc.getElementById) return false;
    var btn = doc.getElementById('lang-btn');
    var menu = doc.getElementById('lang-menu');
    if (!btn || !menu) return false;
    var current = (doc.documentElement && doc.documentElement.lang) || 'en';
    var logical = logicalPathFromUrl(global.location && global.location.pathname);
    function close() { menu.hidden = true; btn.setAttribute('aria-expanded', 'false'); }
    function rebuild(map) {
      buildMenu(doc, menu, logical, current, function (lang, url) {
        setLang(lang);
        global.location.href = url;
      }, map);
    }
    btn.addEventListener('click', function () {
      if (!menu.hidden) { close(); return; }
      menu.hidden = false;
      btn.setAttribute('aria-expanded', 'true');
      rebuild(null);
      if (typeof global.fetch === 'function') {
        global.fetch(LANG_MAP_URL)
          .then(function (r) { return r.ok ? r.json() : null; })
          .then(rebuild)
          .catch(function () { /* 保留回落菜单 */ });
      }
    });
    doc.addEventListener('click', function (e) {
      if (!menu.hidden && !menu.contains(e.target) && e.target !== btn && !btn.contains(e.target)) close();
    });
    return true;
  }

  var api = {
    SUPPORTED_LANGS: SUPPORTED_LANGS,
    STORAGE_KEY: STORAGE_KEY,
    LANG_LABELS: LANG_LABELS,
    mapTag: mapTag,
    pickLang: pickLang,
    setLang: setLang,
    pathForLang: pathForLang,
    getStoredLang: getStoredLang,
    logicalPathFromUrl: logicalPathFromUrl,
    buildMenu: buildMenu,
    initLangMenu: initLangMenu
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;
  } else {
    global.I18n = api;
    // 浏览器自动接线（node require 路径无 document，不会走到这里）
    if (typeof global.document !== 'undefined' && global.document.getElementById) {
      if (global.document.readyState === 'loading') {
        global.document.addEventListener('DOMContentLoaded', function () { initLangMenu(global.document); });
      } else {
        initLangMenu(global.document);
      }
    }
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);
