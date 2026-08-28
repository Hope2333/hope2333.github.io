/* theme.js — 主题引导核心（无框架 / 零外部依赖，原生 JS）
 * 存储：localStorage["site-theme"]
 * 主题值：yin-v1.0（阴·深色）| yang-v1.1（阳·浅色）
 * 无存储时按系统 prefers-color-scheme 选择；切换按钮 #theme-toggle 在此接入。 */
(function () {
  'use strict';
  var KEY = 'site-theme';
  var YIN = 'yin-v1.0';
  var YANG = 'yang-v1.1';

  var stored = null;
  try {
    stored = localStorage.getItem(KEY);
  } catch (e) {
    stored = null; /* 隐私模式等场景下 localStorage 不可用 */
  }

  var theme = stored === YIN || stored === YANG
    ? stored
    : (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? YIN : YANG);

  document.documentElement.dataset.theme = theme;

  var toggle = document.getElementById('theme-toggle');
  if (toggle) {
    toggle.addEventListener('click', function () {
      var current = document.documentElement.dataset.theme;
      var next;
      if (current === YIN) {
        next = YANG;
      } else if (current === YANG) {
        next = YIN;
      } else {
        /* 无值时按系统偏好反推（与引导逻辑一致） */
        next = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? YIN : YANG;
      }
      try {
        localStorage.setItem(KEY, next);
      } catch (e) {
        /* 隐私模式等场景下 localStorage 不可用，仅本次会话生效 */
      }
      document.documentElement.dataset.theme = next;
    });
  }
})();
