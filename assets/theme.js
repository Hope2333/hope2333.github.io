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
  /* C9 首页交互：折叠动效 + aria-expanded 同步（无框架，原生 JS）
   * reduced-motion 用户：跳过动画，原生直接切换；其余：拦截折叠 → 网格 200ms 淡出 → 再切 open。 */
  Array.prototype.forEach.call(document.querySelectorAll('main details'), function (details) {
    var summary = details.querySelector('summary');
    var grid = details.querySelector('.grid');
    if (!summary) return;

    summary.setAttribute('aria-expanded', String(details.open));

    /* toggle 事件覆盖所有路径（原生开/关、JS 延迟关），统一同步 aria-expanded */
    details.addEventListener('toggle', function () {
      summary.setAttribute('aria-expanded', String(details.open));
    });

    summary.addEventListener('click', function (e) {
      if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return; /* reduced-motion：放行原生切换，aria 由 toggle 事件同步 */
      }
      if (!grid || !details.hasAttribute('open')) {
        return; /* 即将展开或无网格：放行原生行为，堆叠条经 CSS 过渡淡入 */
      }
      e.preventDefault();
      grid.classList.add('is-collapsing');
      window.setTimeout(function () {
        details.removeAttribute('open');
        grid.classList.remove('is-collapsing');
      }, 200);
    });
  });
})();
