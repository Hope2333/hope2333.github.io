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

> **最新批次（Push261026）**：v2 **2.1.4** + **2.0.32** native 发布（deb + pacman）— 2.1.4 修复 OpenTUI 0.6.8 ABI 错配（首版 TUI 报 `ot_scene_set_hooks not found`），构建改为按 `OPENTUI_VER` 选渲染库、未知版本硬失败；两版本在 Android 9 / kernel 3.18.140 实测 TUI 完整可用。本批仅 native；v1 仍为 1.19.3（1.19.4 待源码重建）。详见 [Push261026 发布页](release/Push261026.md)。

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
