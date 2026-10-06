---
title: "opencode-termux"
lang: zh-TW
---

> [!NOTE]
> **說明**：本頁內容由簡體中文原文機械轉換為繁體（字級變體轉換，非翻譯）。簡體原文：[/wiki/projects/opencode-termux](/zh_CN/wiki/projects/opencode-termux.md)；根路徑 canonical：[/wiki/projects/opencode-termux](/wiki/projects/opencode-termux.md)。站點已完整中譯的內容從 [繁體 wiki 索引](/zh_TW/wiki/opencode-termux/) 進入。

# opencode-termux

> OpenCode on Termux/Android, the flagship project

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
