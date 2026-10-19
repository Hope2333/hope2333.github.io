---
title: "opencode-termux"
lang: zh-TW
---

# opencode-termux

OpenCode on Termux/Android — 旗艦項目

## 簡介

opencode-termux 將 [OpenCode](https://github.com/anomalyco/opencode) 引入 Termux/Android 環境，通過移植-復活管線產出零 glibc 依賴的原生 Android ELF。`opencode` 包名已成爲穩定主線。

## 五家族 × 兩代矩陣

五個家族、兩代並存（v1 與 v2 可同裝）：

| 包名 | 代 | 狀態 | 運行時 |
|------|----|------|--------|
| **原生（v2 主線）** | v2 | `opencode` | 穩定 — 純 Bionic，零 glibc 依賴 |
| **wrapper（v2 附錄）** | v2 | `opencode-wrapper` | bun-termux-loader 封裝 |
| **原生（v1 主線）** | v1 | `opencode1` | 穩定 — 純 Bionic，零 glibc 依賴 |
| **wrapper（v1 附錄）** | v1 | `opencode1-wrapper` | glibc 運行時載荷 |
| **壓縮（v1）** | v1 | `opencode1-compressed` | UPX 壓制原生（`.pkg.tar.gz`） |

同代內 native / wrapper / compressed 三選一；跨代 v1（`opencode1*`）與 v2（`opencode*`）可共存。舊名 `opencode-glibc`、`opencode-compressed`、`opencode-glibc-standalone` 已退役，並從統一 `[hope2333]` 庫中硬性剔除。

> **最新批次（Push261016）**：**#36 seccomp 修复**（native 补 crhandler interpose，Android 12 close_range 不再 SIGSYS，受影响版本已重打包）+ 新版本 v2 2.0.28–2.0.31 / v1 1.19.1–1.19.3 三族齐发（wrapper 仅 deb），84 资产，rel=1。老內核（< 4.x）注意：opencode 1.18.35 及以上（v1）與所有 v2 的 TUI 啓動即崩（SIGSEGV），CLI 不受影響；老內核建議留在 1.18.34 及以下，或改用 1.19.3 native 混合件（`--force-tui` 恢復 TUI，否則 launcher 自動降級 CLI）。詳見 [Push261016 發佈頁「已知問題」](release/Push261016.md)。

## 快速安裝

```bash
# 通过 hope2333 pacman 源（推荐）
pacman -S opencode     # v2 原生主线
pacman -S opencode1    # v1 原生主线（与 v2 共存）
```

詳見[安裝指南](install.md)。

## 鏈接

- [GitHub](https://github.com/Hope2333/opencode-termux)
- [安裝指南](install.md)
- [從源碼構建](build.md)
- [架構說明](architecture.md)
- [發佈列表（不釘 tag）](https://github.com/Hope2333/opencode-termux/releases)
