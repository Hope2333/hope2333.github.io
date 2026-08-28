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

# 3. 包管理器探测
if command -v pacman >/dev/null 2>&1; then
  echo "检测到包管理器：pacman"
  # pacman 分支（幂等）
  if grep -q '^\[hope2333\]' "$PREFIX/etc/pacman.conf"; then
    echo "hope2333 源已配置，跳过"
  else
    printf '\n[hope2333]\nServer = https://hope2333.github.io/repo/Termux/pacman/\nSigLevel = Optional TrustAll\n' >> "$PREFIX/etc/pacman.conf"
    echo "已添加 hope2333 源到 $PREFIX/etc/pacman.conf"
    pacman -Sy
  fi
elif command -v apt >/dev/null 2>&1; then
  echo "检测到 plain Termux (apt)。本仓库为 pacman 源，先迁移包管理器："
  echo "  curl -fsSL https://github.com/Hope2333/opencode-termux/releases/download/EarlyEmergencyRelease0/init-pacmanV00fix18.sh | sh"
  echo "迁移完成后重新运行本脚本"
  exit 0
else
  echo "未找到 pacman 或 apt，无法继续"
  exit 1
fi
