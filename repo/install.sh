#!/bin/sh
set -eu

# 软件源安装脚本（POSIX sh，可经 curl -fsSL ... | sh 直接运行）
# 目标：Termux (aarch64)。单节自举：统一 [hope2333] 源 + hope2333-mirrorlist 包。
# [hope2333-meta] 引导仓已退役（2026-09-09）：统一库直接收录 hope2333-mirrorlist，
# 本脚本负责把旧布局（[hope2333-meta] 引导节 / 旧单仓 [hope2333] 块 / 无主手放
# conf）迁移到单节终态，并保证幂等重跑收敛（零重复、零 meta 残留、exit 0）。
# 注意：本脚本绝不自动迁移包管理器；plain Termux (apt) 仅配置 apt 引导行。
#
# 用法：
#   install.sh                     仅配置软件源（默认行为）
#   install.sh --install <pkg>     配置软件源并安装指定包
#   install.sh --help              显示本帮助
#   install.sh --selfcheck         无副作用自检：打印所选语言文案与解析出的 server 地址

# ── 0. 语言协商（draft D4：ENV 传参，脚本只维护一份）─────────────────────
#    读环境变量 LANG（en / zh_CN / zh_TW / ja / es，容忍 en_US.UTF-8 形态），
#    缺省 en。文案表仅覆盖人读提示；下载源与源地址行保持单一来源、零改动
#    （含源地址的行不在文案表内、不被本节触碰）。
MSG_LANG=en
pick_lang() {
  _ml="${LANG-}"
  _ml="${_ml%%.*}"
  _ml="${_ml%%@*}"
  case "$_ml" in
    zh_TW*|zh_HK*|zh_Hant*) MSG_LANG=zh_TW ;;
    zh_CN*|zh*)             MSG_LANG=zh_CN ;;
    ja*)                    MSG_LANG=ja ;;
    es*)                    MSG_LANG=es ;;
    *)                      MSG_LANG=en ;;
  esac
}
pick_lang

set_messages() {
  case "$MSG_LANG" in
    zh_CN)
      M_ERR_INSTALL_ARG='错误: --install 需要一个包名参数（如 --install opencode）'
      M_ERR_UNKNOWN_ARG='错误: 未知参数: %s'
      M_PREFIX_FALLBACK='未设置 $PREFIX，回退到 Termux 默认路径：%s'
      M_TERMUX_ONLY='仅支持 Termux（目标 aarch64）'
      M_ARCH='架构：%s'
      M_PACMAN='检测到包管理器：pacman'
      M_ML_UP2DATE='hope2333-mirrorlist 已是最新（%s），跳过重装'
      M_UNIFIED_OK='[hope2333] 统一源已生效（%s 个包）'
      M_APT='检测到 plain Termux (apt)。本仓库为 pacman 源，apt 客户端配置如下（flat 源，包走 Release CDN）：'
      M_NO_PM='未找到 pacman 或 apt，无法继续'
      M_INSTALLING='=== 安装 %s ==='
      M_SC_TITLE='hope2333 软件源安装脚本 — selfcheck（无副作用：不安装、不写盘、不联网）'
      M_SC_LANG='语言 / language: %s（来源：环境变量 LANG，缺省 en）'
      M_SC_ADDR='解析出的源地址（自本脚本既有行提取，单一来源）：'
      M_SC_NOFILE='selfcheck 需以本地脚本文件运行（curl|sh 管道下 $0 不可读）'
      ;;
    zh_TW)
      M_ERR_INSTALL_ARG='錯誤: --install 需要一個套件名參數（如 --install opencode）'
      M_ERR_UNKNOWN_ARG='錯誤: 未知參數: %s'
      M_PREFIX_FALLBACK='未設定 $PREFIX，回退到 Termux 預設路徑：%s'
      M_TERMUX_ONLY='僅支援 Termux（目標 aarch64）'
      M_ARCH='架構：%s'
      M_PACMAN='偵測到套件管理器：pacman'
      M_ML_UP2DATE='hope2333-mirrorlist 已是最新（%s），跳過重裝'
      M_UNIFIED_OK='[hope2333] 統一源已生效（%s 個套件）'
      M_APT='偵測到 plain Termux (apt)。本倉庫為 pacman 源，apt 用戶端設定如下（flat 源，套件走 Release CDN）：'
      M_NO_PM='找不到 pacman 或 apt，無法繼續'
      M_INSTALLING='=== 安裝 %s ==='
      M_SC_TITLE='hope2333 軟體源安裝腳本 — selfcheck（無副作用：不安裝、不寫盤、不連網）'
      M_SC_LANG='語言 / language: %s（來源：環境變數 LANG，預設 en）'
      M_SC_ADDR='解析出的源位址（自本腳本既有行提取，單一來源）：'
      M_SC_NOFILE='selfcheck 需以本地腳本檔案執行（curl|sh 管道下 $0 不可讀）'
      ;;
    ja)
      M_ERR_INSTALL_ARG='エラー: --install にはパッケージ名が必要です（例: --install opencode）'
      M_ERR_UNKNOWN_ARG='エラー: 不明な引数: %s'
      M_PREFIX_FALLBACK='$PREFIX が未設定のため Termux の既定パスにフォールバック: %s'
      M_TERMUX_ONLY='Termux（aarch64）のみ対応しています'
      M_ARCH='アーキテクチャ: %s'
      M_PACMAN='パッケージマネージャを検出: pacman'
      M_ML_UP2DATE='hope2333-mirrorlist は最新（%s）のため再インストールをスキップ'
      M_UNIFIED_OK='[hope2333] 統一リポジトリが有効（%s パッケージ）'
      M_APT='plain Termux (apt) を検出。本リポジトリは pacman 向けのため、apt クライアント設定は次のとおり（flat リポジトリ、パッケージは Release CDN 経由）：'
      M_NO_PM='pacman も apt も見つからず、続行できません'
      M_INSTALLING='=== %s をインストール ==='
      M_SC_TITLE='hope2333 リポジトリインストールスクリプト — selfcheck（副作用なし: インストール・書き込み・通信なし）'
      M_SC_LANG='言語 / language: %s（来源: 環境変数 LANG、既定 en）'
      M_SC_ADDR='解決されたサーバーアドレス（本スクリプトの既存行から抽出、単一ソース）：'
      M_SC_NOFILE='selfcheck はローカルのスクリプトファイルで実行してください（curl|sh パイプでは $0 を読めません）'
      ;;
    es)
      M_ERR_INSTALL_ARG='error: --install requiere un nombre de paquete (p. ej., --install opencode)'
      M_ERR_UNKNOWN_ARG='error: argumento desconocido: %s'
      M_PREFIX_FALLBACK='$PREFIX no definido; se usa la ruta predeterminada de Termux: %s'
      M_TERMUX_ONLY='solo se admite Termux (aarch64)'
      M_ARCH='arquitectura: %s'
      M_PACMAN='gestor de paquetes detectado: pacman'
      M_ML_UP2DATE='hope2333-mirrorlist ya está actualizado (%s); se omite la reinstalación'
      M_UNIFIED_OK='[hope2333] repositorio unificado activo (%s paquetes)'
      M_APT='se detectó plain Termux (apt). Este repositorio es para pacman; la configuración del cliente apt es la siguiente (repositorio flat, paquetes vía Release CDN):'
      M_NO_PM='no se encontró pacman ni apt; no se puede continuar'
      M_INSTALLING='=== instalando %s ==='
      M_SC_TITLE='script de instalación del repositorio hope2333 — selfcheck (sin efectos: no instala, no escribe, no accede a la red)'
      M_SC_LANG='idioma / language: %s (origen: variable de entorno LANG, predeterminado en)'
      M_SC_ADDR='direcciones de servidor resueltas (extraídas de las líneas existentes de este script, fuente única):'
      M_SC_NOFILE='selfcheck requiere ejecutar el archivo de script local (con curl|sh no se puede leer $0)'
      ;;
    *)
      M_ERR_INSTALL_ARG='error: --install requires a package name (e.g. --install opencode)'
      M_ERR_UNKNOWN_ARG='error: unknown argument: %s'
      M_PREFIX_FALLBACK='$PREFIX not set; falling back to Termux default path: %s'
      M_TERMUX_ONLY='only Termux (aarch64) is supported'
      M_ARCH='architecture: %s'
      M_PACMAN='package manager detected: pacman'
      M_ML_UP2DATE='hope2333-mirrorlist is up to date (%s); skipping reinstall'
      M_UNIFIED_OK='[hope2333] unified repository is active (%s packages)'
      M_APT='plain Termux (apt) detected. This repository is a pacman repo; the apt client configuration is as follows (flat repo, packages via Release CDN):'
      M_NO_PM='neither pacman nor apt found; cannot continue'
      M_INSTALLING='=== installing %s ==='
      M_SC_TITLE='hope2333 repository install script — selfcheck (no side effects: no install, no writes, no network)'
      M_SC_LANG='language: %s (source: LANG environment variable, default en)'
      M_SC_ADDR='resolved server addresses (extracted from existing lines of this script, single source):'
      M_SC_NOFILE='selfcheck must run from a local script file ($0 unreadable under curl|sh)'
      ;;
  esac
}
set_messages

print_server_lines() {
  # 仅提取本脚本既有行的源地址（行内兜底节 + 内置快照），不新增/不复制任何 URL 字面量
  if [ ! -f "$0" ]; then
    printf '%s\n' "$M_SC_NOFILE" >&2
    return 1
  fi
  sed -n 's|.*\(Serv[e]r = https:[^\\]*\)\\n.*|\1|p' "$0"
  awk '/^Serv[e]r = / && /https:/ { print }' "$0"
}
# 一行命令（远程执行时参数经 sh -s -- 传递）：
#   curl -fsSL https://hope2333.github.io/repo/install.sh | sh
#   curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode

usage() {
  cat <<EOF
hope2333 软件源安装脚本（Termux, aarch64）

用法:
  install.sh                 仅配置软件源（默认行为，与无参一致）
  install.sh --install <pkg> 配置软件源并安装指定包
                             （入源包: opencode / opencode-compressed / opencode-glibc /
                               mimocode / mimocode-glibc / codegraph / freebuff / codebuff）
  install.sh --help          显示本帮助
  install.sh --selfcheck     无副作用自检：打印所选语言文案与解析出的 server 地址

一行命令:
  curl -fsSL https://hope2333.github.io/repo/install.sh | sh
  curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
EOF
}

INSTALL_PKG=""
case "${1-}" in
  "") ;;
  -h|--help)
    usage
    exit 0
    ;;
  --selfcheck)
    SELFCHECK=1
    ;;
  --install)
    [ $# -ge 2 ] || {
      printf '%s\n' "$M_ERR_INSTALL_ARG" >&2
      usage >&2
      exit 1
    }
    INSTALL_PKG="$2"
    shift 2
    ;;
  *)
    printf "$M_ERR_UNKNOWN_ARG\n" "$1" >&2
    usage >&2
    exit 1
    ;;
esac

# ── --selfcheck：无副作用诊断（打印文案与解析出的源地址后即退出；
#    先于任何 Termux 探测/安装/写盘/联网动作）─────────────────────────────
if [ "${SELFCHECK-}" = "1" ]; then
  printf '%s\n' "$M_SC_TITLE"
  printf "$M_SC_LANG\n" "$MSG_LANG"
  printf '%s\n' "$M_SC_ADDR"
  print_server_lines
  exit 0
fi

# 1. Termux 探测
if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX" ]; then
  :
elif [ -d /data/data/com.termux/files/usr ]; then
  PREFIX=/data/data/com.termux/files/usr
  printf "$M_PREFIX_FALLBACK\n" "$PREFIX"
else
  printf '%s\n' "$M_TERMUX_ONLY"
  exit 1
fi

# 2. 架构信息（仅诊断输出，绝不作为分支依据）
printf "$M_ARCH\n" "$(uname -m)"
if command -v termux-info >/dev/null 2>&1; then
  echo "--- termux-info 诊断 ---"
  termux-info | sed -n '1,8p'
fi

# 3. 包管理器探测与引导
if command -v pacman >/dev/null 2>&1; then
  printf '%s\n' "$M_PACMAN"
  P="$PREFIX"
  PACMAN_CONF="$P/etc/pacman.conf"
  ML_CONF="$P/etc/pacman.d/hope2333-mirrorlist.conf"
  ML_SHARE="$P/share/hope2333-mirrorlist/mirrorlist.conf"
  [ -f "$PACMAN_CONF" ] || { echo "错误: 未找到 $PACMAN_CONF"; exit 1; }

  # ── 0. RootDir 约定回落 / + 叠影哨兵（phase0 2026-10-04）───────────────
  # 约定反转：hope2333 源的 pacman 包成员已是 termux-pacman 官方绝对路径
  # data/data/com.termux/files/usr/...（无前导 /），事务根必须回落编译
  # 默认 /。旧自愈把 RootDir 写死为 /data/data/com.termux/files —— 在绝对
  # 成员约定下会让 pacman 把成员二次前缀灌进 <RootDir>/data/...（叠影），
  # 故废弃写死逻辑：① RootDir 行一律注释（alpm 回落 /）；② DBPath 等
  # 路径指令缺失时补绝对路径（RootDir=/ 下缺失会把编译默认 dbpath 再拼
  # 上 RootDir → 双重路径找不到库）；③ HookDir/GPGDir 目录不存在会被
  # pacman 解析直接拒绝（先建目录）。
  if grep -qE '^[[:space:]]*RootDir' "$PACMAN_CONF"; then
    sed -i 's|^[[:space:]]*RootDir[[:space:]]*=.*|#RootDir = / (phase0: absolute-member convention — alpm falls back to compiled default /)|' "$PACMAN_CONF"
  fi
  if ! grep -q '^DBPath' "$PACMAN_CONF"; then
    sed -i "/^\[options\]/a DBPath = $P/var/lib/pacman/\nLogFile = $P/var/log/pacman.log\nCacheDir = $P/var/cache/pacman/pkg/\nHookDir = $P/etc/pacman.d/hooks/\nGPGDir = $P/etc/pacman.d/gnupg/" "$PACMAN_CONF"
  fi
  mkdir -p "$P/etc/pacman.d/hooks" "$P/etc/pacman.d/gnupg" "$P/var/lib/pacman" "$P/var/cache/pacman/pkg" "$P/var/log"
  if grep -qE '^[[:space:]]*RootDir' "$PACMAN_CONF"; then
    echo "错误: pacman.conf RootDir 注释失败（存在未注释的 RootDir 行）；请手工编辑 $PACMAN_CONF 后重试" >&2
    exit 1
  fi
  # 叠影哨兵（fix20 语义）：历史坏约定机器在 $PREFIX 上级（RootDir=$PREFIX
  # 上级时）或 $PREFIX 下（RootDir=$PREFIX 时）留有非空的
  # data/com.termux/files/usr 叠影子树 —— 空壳不算病，存在实体文件才算
  # （与 mirrorlist 包 repair-doubled.sh 同判据）。检出即红字提示，不阻塞
  # 源配置（叠影不参与新事务），但应尽快清理。
  SHADOW_HITS=""
  for shadow_top in "$P/../data" "$P/data"; do
    if [ -d "$shadow_top/data/com.termux/files/usr" ] && \
       [ -n "$(find "$shadow_top/data/com.termux/files/usr" -type f -print -quit 2>/dev/null)" ]; then
      SHADOW_HITS="$SHADOW_HITS $shadow_top"
    fi
  done
  if [ -n "$SHADOW_HITS" ]; then
    printf '\033[31m警告: 检出叠影目录（历史 RootDir 坏约定遗留的实体文件树）:%s\033[0m\n' "$SHADOW_HITS"
    printf '\033[31m请运行 fix20 修复脚本清理（opencode-termux 仓 packing/init-pacmanV00fix20.sh，\n或 mirrorlist 包自带的 repair-doubled.sh），否则残留旧版二进制可能遮蔽新装文件。\033[0m\n'
  else
    echo "RootDir 回落 /（已注释；绝对成员约定），叠影哨兵未检出异常"
  fi

  # ── A. 迁移预清理（幂等）───────────────────────────────────────────────
  # A1. [hope2333-meta] 引导节整体退役：从节头删到下一节头/文件尾。
  #     B1 时代钩子盲追加到 EOF 的 Include 行落在该节作用域内，随之一起清除。
  if grep -q '^\[hope2333-meta\]' "$PACMAN_CONF"; then
    awk '
/^\[hope2333-meta\]$/ { inmeta = 1; next }
/^\[/ { inmeta = 0; print; next }
inmeta { next }
{ print }
' "$PACMAN_CONF" > "$PACMAN_CONF.tmp" && mv "$PACMAN_CONF.tmp" "$PACMAN_CONF"
    echo "已退役 [hope2333-meta] 引导节（统一源直接收录 hope2333-mirrorlist）"
  fi
  # A2. 无主手放 conf 会触发 .pacnew：包未安装时先删，让包自带完整托管副本；
  #     包已安装则 conf 归包所有，绝不触碰（backup= 机制保护用户改动）。
  if ! pacman -Q hope2333-mirrorlist >/dev/null 2>&1 && [ -f "$ML_CONF" ]; then
    rm -f "$ML_CONF"
    echo "已移除无主手放 conf（将由 hope2333-mirrorlist 包提供托管副本）"
  fi

  # ── B. 布局修复 + 引导节准备 ──────────────────────────────────────────
  #     终态契约：pacman.conf 内不得有 [hope2333] 节——托管 conf 自带
  #     [hope2333] 节头，经 Include 内联完成唯一注册；pacman.conf 再写同名
  #     节会双重注册并被 pacman 丢弃 Server（实测：database already
  #     registered → no servers configured for repository）。故先删除任何
  #     [hope2333] 节（旧单仓块/引导残留/错误中间态），Include 未接线时
  #     再追加临时引导节（Pages 内联 Server）拉起首装。
  awk '
/^\[hope2333\]$/ { inhope = 1; next }
/^\[/ { inhope = 0; print; next }
inhope { next }
{ print }
' "$PACMAN_CONF" > "$PACMAN_CONF.tmp" && mv "$PACMAN_CONF.tmp" "$PACMAN_CONF"
  if ! grep -q 'pacman.d/hope2333-mirrorlist.conf' "$PACMAN_CONF"; then
    printf '\n[hope2333]\nServer = https://hope2333.github.io/repo/Termux/pacman/\nSigLevel = Optional TrustAll\n' >> "$PACMAN_CONF"
  fi

  # ── C. 刷新源 ─────────────────────────────────────────────────────────
  pacman -Sy

  # ── D. 安装/升级 mirrorlist 包 ────────────────────────────────────────
  #     同版本跳过重装（幂等；也避开本机 scriptlet 损坏时的无谓事务）。
  inst="$(pacman -Q hope2333-mirrorlist 2>/dev/null | awk '{print $2}')"
  avail="$(pacman -Si hope2333-mirrorlist 2>/dev/null | awk '/^Version/{print $3; exit}')"
  if [ -z "$inst" ] || { [ -n "$avail" ] && [ "$inst" != "$avail" ]; }; then
    if ! pacman -S --noconfirm hope2333-mirrorlist; then
      echo "自动安装失败，请按 https://hope2333.github.io/repo/Termux/pacman/ 手动配置"
      exit 1
    fi
  else
    printf "$M_ML_UP2DATE\n" "$inst"
  fi

  # ── E. 终态收敛：无 [hope2333] 节 + EOF Include ───────────────────────
  #     钩子 v10 同样会做（删节 + EOF 接线），此处为权威兜底——本机
  #     scriptlet 可能损坏，钩子不保证执行。
  #     极端情况兜底：钩子未落 conf 时从包内 share 副本恢复（v8.2 遗留自愈，
  #     修正了旧版 $P/usr/share 的错误路径），再不行用内置快照。
  if [ ! -f "$ML_CONF" ] && [ -f "$ML_SHARE" ]; then
    mkdir -p "$(dirname "$ML_CONF")"
    install -m644 "$ML_SHARE" "$ML_CONF"
    echo "从包内 share 副本恢复托管 conf"
  fi
  if [ ! -f "$ML_CONF" ]; then
    echo "警告: 托管 conf 缺失且包内 share 副本不可用，写入内置快照"
    mkdir -p "$(dirname "$ML_CONF")"
    cat > "$ML_CONF" <<'MIRRORLIST'
[hope2333]
Server = https://github.com/Hope2333/codegraph-termux/releases/latest/download/
Server = https://github.com/Hope2333/opencode-termux/releases/latest/download/
Server = https://github.com/Hope2333/MiMoCode-Termux/releases/download/Push260829/
Server = https://github.com/Hope2333/freebuff-termux/releases/latest/download/
Server = https://github.com/Hope2333/codebuff-termux/releases/latest/download/
Server = https://hope2333.github.io/repo/Termux/pacman/
SigLevel = Optional TrustAll
MIRRORLIST
  fi
  if grep -q '^\[hope2333\]' "$PACMAN_CONF"; then
    awk '
/^\[hope2333\]$/ { inhope = 1; next }
/^\[/ { inhope = 0; print; next }
inhope { next }
{ print }
' "$PACMAN_CONF" > "$PACMAN_CONF.tmp" && mv "$PACMAN_CONF.tmp" "$PACMAN_CONF"
  fi
  grep -q 'pacman.d/hope2333-mirrorlist.conf' "$PACMAN_CONF" || printf '\nInclude = %s\n' "$ML_CONF" >> "$PACMAN_CONF"

  # ── F. 验证（-Sy 全绿证明终态布局的 Server 解析可用）─────────────────
  if ! sync_out="$(pacman -Sy 2>&1)"; then
    if printf '%s\n' "$sync_out" | grep -q 'no servers configured for repository\|could not register'; then
      echo "错误: [hope2333] 源布局异常（双重注册/无 Server）："
      printf '%s\n' "$sync_out" | grep -E 'error|could not|no servers' || true
      exit 1
    fi
    echo "警告: pacman -Sy 部分失败（非 hope2333 布局问题，多为 Termux 镜像抖动），继续"
  fi
  if ! pacman -Sl hope2333 >/dev/null 2>&1; then
    echo "错误: [hope2333] 统一源未生效（检查网络，或按 https://hope2333.github.io/wiki/guides/software-source.html 手动配置）"
    exit 1
  fi
  printf "$M_UNIFIED_OK\n" "$(pacman -Sl hope2333 | wc -l)"

elif command -v apt >/dev/null 2>&1; then
  printf '%s\n' "$M_APT"
  BOOTSTRAP_LIST="$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list"
  mkdir -p "$(dirname "$BOOTSTRAP_LIST")"
  if [ ! -f "$BOOTSTRAP_LIST" ] || ! grep -q 'hope2333.github.io/repo/Termux/apt' "$BOOTSTRAP_LIST"; then
    printf 'deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./\n' > "$BOOTSTRAP_LIST"
  fi
  apt update
  apt install -y hope2333-mirrorlist
else
  printf '%s\n' "$M_NO_PM"
  exit 1
fi

# 4. 可选：--install <pkg>（配置完成后追加安装步骤）
if [ -n "$INSTALL_PKG" ]; then
  printf "$M_INSTALLING\n" "$INSTALL_PKG"
  if command -v pacman >/dev/null 2>&1; then
    pacman -Sy
    pacman -S --noconfirm "$INSTALL_PKG"
  else
    apt install -y "$INSTALL_PKG"
  fi
fi
