#!/bin/sh
set -eu

# 软件源安装脚本（POSIX sh，可经 curl -fsSL ... | sh 直接运行）
# 目标：Termux (aarch64)。自动探测环境，幂等写入 hope2333 源。
# 注意：本脚本绝不自动迁移包管理器；plain Termux (apt) 仅打印迁移指引。

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
  PACMAN_CONF="$PREFIX/etc/pacman.conf"
  BOOTSTRAP_LIST="$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list"

  if grep -q '^\[hope2333-meta\]' "$PACMAN_CONF"; then
    # State 3: 已引导，确保 mirrorlist 包存在即可，跳过其余流程
    pacman -Q hope2333-mirrorlist >/dev/null 2>&1 || pacman -S --noconfirm hope2333-mirrorlist
  else
    # State 2: 旧版单仓块迁移（删除 [hope2333] 段至首个 SigLevel 行，含；不动其他段）
    if grep -q '^\[hope2333\]' "$PACMAN_CONF"; then
      awk '
/^\[hope2333\]/ { skip=1; next }
skip && /^SigLevel/ { skip=0; next }
skip && /^\[/ { skip=0 }
skip { next }
{ print }
' "$PACMAN_CONF" > "$PACMAN_CONF.tmp" && mv "$PACMAN_CONF.tmp" "$PACMAN_CONF"
      echo "检测到旧版单仓配置，已迁移为引导源 + mirrorlist 包"
    fi
    # State 1/2 引导流程
    if ! grep -q '^\[hope2333-meta\]' "$PACMAN_CONF"; then
      printf '\n[hope2333-meta]\nServer = https://hope2333.github.io/repo/Termux/pacman/\nSigLevel = Optional TrustAll\n' >> "$PACMAN_CONF"
    fi
    pacman -Sy
    if ! pacman -S --noconfirm hope2333-mirrorlist; then
      echo "自动安装失败，请按 https://hope2333.github.io/repo/Termux/pacman/ 手动配置"
      exit 1
    fi
    # apt 侧引导（bootstrap.list 持久保留，承载 mirrorlist deb 升级）
    # 注意：pacman 系 Termux 上 apt 常为语义不明的 shim，失败不得中断已成功的 pacman 流程
    mkdir -p "$(dirname "$BOOTSTRAP_LIST")"
    if [ ! -f "$BOOTSTRAP_LIST" ] || ! grep -q 'hope2333.github.io/repo/Termux/apt' "$BOOTSTRAP_LIST"; then
      printf 'deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./\n' > "$BOOTSTRAP_LIST"
    fi
    apt update || echo "apt update 失败（pacman 源已就绪，可忽略）"
    apt install -y hope2333-mirrorlist || echo "apt 安装 hope2333-mirrorlist 失败（pacman 源已就绪，可忽略）"
  fi
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
