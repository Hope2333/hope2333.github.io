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
  --install)
    [ $# -ge 2 ] || {
      echo "错误: --install 需要一个包名参数（如 --install opencode）" >&2
      usage >&2
      exit 1
    }
    INSTALL_PKG="$2"
    shift 2
    ;;
  *)
    echo "错误: 未知参数: $1" >&2
    usage >&2
    exit 1
    ;;
esac

# 1. Termux 探测
if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX" ]; then
  :
elif [ -d /data/data/com.termux/files/usr ]; then
  PREFIX=/data/data/com.termux/files/usr
  echo "未设置 \$PREFIX，回退到 Termux 默认路径：$PREFIX"
else
  echo "仅支持 Termux（目标 aarch64）"
  exit 1
fi

# 2. 架构信息（仅诊断输出，绝不作为分支依据）
echo "架构：$(uname -m)"
if command -v termux-info >/dev/null 2>&1; then
  echo "--- termux-info 诊断 ---"
  termux-info | sed -n '1,8p'
fi

# 3. 包管理器探测与引导
if command -v pacman >/dev/null 2>&1; then
  echo "检测到包管理器：pacman"
  P="$PREFIX"
  PACMAN_CONF="$P/etc/pacman.conf"
  ML_CONF="$P/etc/pacman.d/hope2333-mirrorlist.conf"
  ML_SHARE="$P/share/hope2333-mirrorlist/mirrorlist.conf"
  [ -f "$PACMAN_CONF" ] || { echo "错误: 未找到 $PACMAN_CONF"; exit 1; }

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

  # ── B. 引导节准备（仅当 Include 尚未接线）─────────────────────────────
  #     把 [hope2333]（旧单仓块或残留半成品）收敛为引导形态：节头 + Pages
  #     内联 Server + SigLevel。conf 文件此刻尚不存在，Include 会失败，
  #     故必须先有可用内联 Server 才能拉到统一库（内含 hope2333-mirrorlist）。
  if ! grep -q 'pacman.d/hope2333-mirrorlist.conf' "$PACMAN_CONF"; then
    awk '
/^\[hope2333\]$/ { inhope = 1; if (!done) { print; print "Server = https://hope2333.github.io/repo/Termux/pacman/"; print "SigLevel = Optional TrustAll"; done = 1 } next }
/^\[/ { inhope = 0; print; next }
inhope { next }
{ print }
END { if (!done) { print ""; print "[hope2333]"; print "Server = https://hope2333.github.io/repo/Termux/pacman/"; print "SigLevel = Optional TrustAll" } }
' "$PACMAN_CONF" > "$PACMAN_CONF.tmp" && mv "$PACMAN_CONF.tmp" "$PACMAN_CONF"
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
    echo "hope2333-mirrorlist 已是最新（$inst），跳过重装"
  fi

  # ── E. 终态收敛：[hope2333] = 节头 + Include ──────────────────────────
  #     钩子 v10 同样会做（section-aware 接线 + 清理内联 Server/SigLevel），
  #     此处为权威兜底——本机 scriptlet 可能损坏，钩子不保证执行。
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
  awk -v inc="Include = $ML_CONF" '
/^\[hope2333\]$/ { inhope = 1; if (!done) { print; print inc; done = 1 } next }
/^\[/ { inhope = 0; print; next }
inhope { next }
{ print }
END { if (!done) { print ""; print "[hope2333]"; print inc } }
' "$PACMAN_CONF" > "$PACMAN_CONF.tmp" && mv "$PACMAN_CONF.tmp" "$PACMAN_CONF"

  # ── F. 验证 ───────────────────────────────────────────────────────────
  if ! pacman -Sl hope2333 >/dev/null 2>&1; then
    echo "错误: [hope2333] 统一源未生效（检查网络，或按 https://hope2333.github.io/wiki/guides/software-source.html 手动配置）"
    exit 1
  fi
  echo "[hope2333] 统一源已生效（$(pacman -Sl hope2333 | wc -l) 个包）"

elif command -v apt >/dev/null 2>&1; then
  echo "检测到 plain Termux (apt)。本仓库为 pacman 源，apt 客户端配置如下（flat 源，包走 Release CDN）："
  BOOTSTRAP_LIST="$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list"
  mkdir -p "$(dirname "$BOOTSTRAP_LIST")"
  if [ ! -f "$BOOTSTRAP_LIST" ] || ! grep -q 'hope2333.github.io/repo/Termux/apt' "$BOOTSTRAP_LIST"; then
    printf 'deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./\n' > "$BOOTSTRAP_LIST"
  fi
  apt update
  apt install -y hope2333-mirrorlist
else
  echo "未找到 pacman 或 apt，无法继续"
  exit 1
fi

# 4. 可选：--install <pkg>（配置完成后追加安装步骤）
if [ -n "$INSTALL_PKG" ]; then
  echo "=== 安装 $INSTALL_PKG ==="
  if command -v pacman >/dev/null 2>&1; then
    pacman -Sy
    pacman -S --noconfirm "$INSTALL_PKG"
  else
    apt install -y "$INSTALL_PKG"
  fi
fi
