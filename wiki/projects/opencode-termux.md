# opencode-termux

> OpenCode on Termux/Android, the flagship project

## 简介

OpenCode on Termux/Android，是 Hope2333 的旗舰项目。项目让 OpenCode 运行在 Termux/Android 环境中，是本站收录项目里最核心的一个。

## 安装

该项目已进入 hope2333 软件源（pacman，统一源名 `[hope2333]`：各仓 release 库存优先，本站回退），推荐直接安装：

```bash
# 原生主线（推荐）
pacman -S opencode

# glibc 附录（自包含复合体，bin-only）
pacman -S opencode-glibc

# 压缩变体（UPX，自带 crhandler shim）
pacman -S opencode-compressed
```

详见 [wiki 安装指南](/wiki/opencode-termux/install.html)。

## 链接

- **Wiki**：[/wiki/opencode-termux/](/wiki/opencode-termux/)
- GitHub 仓库：<https://github.com/Hope2333/opencode-termux>
- 发布列表（不钉 tag）：<https://github.com/Hope2333/opencode-termux/releases>
