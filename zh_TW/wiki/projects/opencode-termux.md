---
title: "opencode-termux"
lang: zh-TW
---

# opencode-termux

> OpenCode on Termux/Android，旗艦項目

## 簡介

OpenCode on Termux/Android，是 Hope2333 的旗艦項目。項目讓 OpenCode 運行在 Termux/Android 環境中，是本站收錄項目裏最核心的一個。

## 安裝

該項目已進入 hope2333 軟件源（pacman，統一源名 `[hope2333]`：各倉 release 庫存優先，本站回退），推薦直接安裝：

```bash
# 原生主线（推荐）
pacman -S opencode

# glibc 附录（自包含复合体，bin-only）
pacman -S opencode-glibc

# 压缩变体（UPX，自带 crhandler shim）
pacman -S opencode-compressed
```

詳見 [wiki 安裝指南](/wiki/opencode-termux/install.md)。

## 鏈接

- **Wiki**：[/wiki/opencode-termux/](/wiki/opencode-termux/)
- GitHub 倉庫：<https://github.com/Hope2333/opencode-termux>
- 發佈列表（不釘 tag）：<https://github.com/Hope2333/opencode-termux/releases>
