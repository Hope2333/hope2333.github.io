#!/usr/bin/env bash
set -euo pipefail
# gen-redirects.sh — 旧 zh_CN 路径的构建期静态跳转页生成器（OQ-2：长期不下线、无服务端 301）
#
# 消费 wiki/tpl/lang-map.json，为每条 zh_CN 登记生成：
#   _site/<旧路径>.html    meta refresh + i18n.js 语言协商双保险（仓内直产 .html，禁同名 .md——
#                          旧路径已无 md 源，若生成 .md 会被渲染循环用 doc.html 模板覆盖、丢 refresh）
#   _site/redirects.tsv    对账 manifest（每行：旧相对路径<TAB>新站内URL，新 URL 带前导斜杠）
#
# 旧路径推导规则（统一机械规则；对 13 个史实旧路径逐字复现）：
#   key "wiki/<a>/<rest...>" → "wiki/<a>/zh_CN/<rest...>"（+ .html）
#   两段键（如 wiki/index）→ "wiki/index/zh_CN"
#
# 幂等：重跑整体覆盖。必须在渲染循环（tools/render-one.sh --all）之后运行，repo/ 不涉及。

MAP="wiki/tpl/lang-map.json"
OUT="_site"
TSV="$OUT/redirects.tsv"

[ -f "$MAP" ] || { echo "gen-redirects: $MAP not found (run at repo root)" >&2; exit 1; }
mkdir -p "$OUT"
: > "$TSV"

legacy_path() {
  local key="$1" rest first
  rest="${key#wiki/}"
  first="${rest%%/*}"
  if [ "$rest" = "$first" ]; then
    printf 'wiki/%s/zh_CN.html' "$first"
  else
    printf 'wiki/%s/zh_CN/%s.html' "$first" "${rest#*/}"
  fi
}

gen_page() {
  local old="$1" new="$2" key="$3" page
  page="$OUT/$old"
  mkdir -p "$(dirname "$page")"
  cat > "$page" <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="0; url=$new">
<title>Redirecting…</title>
<script src="/assets/i18n.js"></script>
</head>
<body>
<p>Redirecting… <a href="$new">$new</a></p>
<script>
(function () {
  var KEY = "$key";
  var FALLBACK = "$new";
  function go(u) { window.location.replace(u); }
  var I = window.I18n;
  var langs = (navigator.languages && navigator.languages.length) ? navigator.languages
            : (navigator.language ? [navigator.language] : []);
  var lang = I ? I.pickLang(langs, I.getStoredLang()) : "zh_CN";
  if (typeof window.fetch !== "function") { go(FALLBACK); return; }
  window.fetch("/wiki/tpl/lang-map.json").then(function (r) { return r.ok ? r.json() : null; })
    .then(function (m) {
      var e = m && m[KEY];
      var u = e && e.alternates && e.alternates[lang];
      if (!u) { go(FALLBACK); return; }
      go(u.charAt(0) === "/" ? u + ".html" : "/" + u + ".html");
    })
    .catch(function () { go(FALLBACK); });
})();
</script>
</body>
</html>
EOF
}

jq -r 'to_entries[]
       | select(.value.alternates.zh_CN != null)
       | [.key, .value.alternates.zh_CN] | @tsv' "$MAP" | \
while IFS=$'\t' read -r key zhcns; do
  old="$(legacy_path "$key")"
  new="/${zhcns}.html"
  gen_page "$old" "$new" "$key"
  printf '%s\t%s\n' "$old" "$new" >> "$TSV"
done

echo "gen-redirects: $(wc -l < "$TSV") redirect pages + manifest"
