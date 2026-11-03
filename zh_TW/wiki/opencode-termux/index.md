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

> **最新批次（Push261104）**：終端修正 + wrapper 雙代全量補齊 —— v2 native **2.2.5-2**（PTY 修復）與 v1 native **1.19.4-2**（TUI 輸入修復），wrapper 補齊至 v2 **2.0.0–2.2.5**（43 版）與 v1 **1.18.30–1.19.5**（12 版），共 **116 個資產**。詳見 [Push261104 發佈頁](release/Push261104.md)。

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
