---
title: "架構說明"
lang: zh-TW
---

> [!NOTE]
> **說明**：本頁內容由簡體中文原文機械轉換為繁體（字級變體轉換，非翻譯）。簡體原文：[/wiki/opencode-termux/architecture](/zh_CN/wiki/opencode-termux/architecture.md)；根路徑 canonical：[/wiki/opencode-termux/architecture](/wiki/opencode-termux/architecture.md)。站點已完整中譯的內容從 [繁體 wiki 索引](/zh_TW/wiki/opencode-termux/) 進入。

# 架構說明

## 移植管線

核心創新：將 OpenCode 的 JavaScript 模塊圖植入官方 Android Bun ELF，再執行「復活手術」產出單個 Bionic 可執行文件。

```
官方 Bun ELF → 提取 → 模块图插入 → 修补 → 组装 → 复活 → 可用二进制
```

## Seccomp SIGSYS Shim

雙層保護：
- **Handler**：內聯 syscall 攔截 + DT_NEEDED[0] interposer
- **PLT interposer**：捕獲子進程 syscall

## TUI（libopentui.so）

自構建 bionic `libopentui.so`（NDK 編譯），通過 `swap_tui.py` 等長替換植入。

## 原生 Watcher

`tools/watcher/` 提供獨立文件監控守護進程：
- `watcher.c` — NDK inotify 遞歸監控
- `shim.js` — 插件側接口
- E2E：三種事件類型 <100ms，自愈 ≤612ms

## 包格式

- `bin/opencode` 爲真實可執行 ELF（無 bash 包裝器）
- 三包互斥：opencode ↔ opencode-glibc ↔ opencode-compressed
