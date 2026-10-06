#!/usr/bin/env bash
set -euo pipefail
# render-one.sh — 站点 wiki 渲染的唯一真源：CI（.github/workflows/site.yml 渲染 step）
# 与本地共用本脚本，消除双源参数漂移。
#
# 用法（须在仓根执行）:
#   bash tools/render-one.sh <md>    渲染单个 md → _site 同名 .html，打印产物路径
#   bash tools/render-one.sh --all   按 CI 完全相同的 find 范围渲染全部 md 到 _site
#
# find 范围: 根 wiki/（排除 wiki/tpl/）+ 各语言目录 <LANG>/（en zh_CN zh_TW ja es，
# 排除其 repo/ 子树——repo/ 不渲染）。渲染循环 find 范围扩至 <LANG>/wiki/**/*.md，
# 否则 LANG 前置页面只落裸 md 不渲染 html。

LANGS="en zh_CN zh_TW ja es"

# lang 按路径推断: 顶层 <LANG>/ 或嵌套 */<LANG>/ 段（后者兜住搬迁完成前的
# 过渡态 wiki/**/zh_CN 路径），其余（根 wiki/ 英文 canonical）→ en。
infer_lang() {
  case "$1" in
    zh_CN/*|*/zh_CN/*) printf 'zh-CN' ;;
    zh_TW/*|*/zh_TW/*) printf 'zh-TW' ;;
    ja/*|*/ja/*)       printf 'ja' ;;
    es/*|*/es/*)       printf 'es' ;;
    *)                 printf 'en' ;;
  esac
}

render_one() {
  local f="$1"
  local out="_site/${f%.md}.html"
  mkdir -p "$(dirname "$out")"
  pandoc "$f" -f gfm -t html5 --template wiki/tpl/doc.html \
    --metadata lang="$(infer_lang "$f")" \
    --metadata title="$(basename "$f" .md)" \
    -o "$out"
  printf '%s\n' "$out"
}

collect_md() {
  find wiki -name '*.md' -not -path 'wiki/tpl/*' -print0
  local l
  for l in $LANGS; do
    [ -d "$l" ] || continue
    find "$l" -name '*.md' -not -path "$l/repo/*" -print0
  done
}

main() {
  if [ "${1:-}" = "--all" ]; then
    while IFS= read -r -d '' f; do
      render_one "$f"
    done < <(collect_md)
  elif [ "$#" -eq 1 ]; then
    [ -f "$1" ] || { printf 'render-one: no such file: %s\n' "$1" >&2; exit 1; }
    render_one "$1"
  else
    printf 'usage: render-one.sh <md> | render-one.sh --all\n' >&2
    exit 1
  fi
}

main "$@"
