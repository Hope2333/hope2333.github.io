---
title: "opencode-termux"
lang: en
---

# opencode-termux

OpenCode on Termux/Android — flagship project.

## Overview

opencode-termux brings [OpenCode](https://github.com/anomalyco/opencode) to Termux/Android via a native Bionic runtime. The project produces a single zero-glibc Android ELF through a transplant-revive pipeline, shipped as formal releases under the `opencode` package name.

## Package Families

Five families across two generations, installable side by side (v1 and v2 coexist):

| Package | Gen | Status | Runtime |
|---------|-----|--------|---------|
| **Native (mainline)** | v2 | `opencode` | Stable — pure Bionic, zero glibc deps |
| **Wrapper (appendix)** | v2 | `opencode-wrapper` | Bun-termux-loader wrapper |
| **Native (v1 mainline)** | v1 | `opencode1` | Stable — pure Bionic, zero glibc deps |
| **Wrapper (v1 appendix)** | v1 | `opencode1-wrapper` | Glibc runtime payload |
| **Compressed (v1)** | v1 | `opencode1-compressed` | UPX-packed native (`.pkg.tar.gz`) |

Within one generation pick exactly ONE of native / wrapper / compressed; v1 (`opencode1*`) and v2 (`opencode*`) coexist. Legacy names `opencode-glibc`, `opencode-compressed` and `opencode-glibc-standalone` are retired and hard-dropped from the unified `[hope2333]` db.

> **最新批次（Push261026）**：v2 **2.1.4** + **2.0.32** native 发布（deb + pacman）— 2.1.4 修复 OpenTUI 0.6.8 ABI 错配（首版 TUI 报 `ot_scene_set_hooks not found`），构建改为按 `OPENTUI_VER` 选渲染库、未知版本硬失败；两版本在 Android 9 / kernel 3.18.140 实测 TUI 完整可用。本批仅 native；v1 仍为 1.19.3（1.19.4 待源码重建）。详见 [Push261026 发布页](release/Push261026.md)。

## Quick Install

```bash
# Via hope2333 pacman source (recommended)
pacman -S opencode     # v2 native mainline
pacman -S opencode1    # v1 native mainline (coexists with v2)
```

See [install guide](install.md) for details.

## Links

- [GitHub](https://github.com/Hope2333/opencode-termux)
- [Install guide](install.md)
- [Build from source](build.md)
- [Architecture](architecture.md)
- [Releases (no tag pin)](https://github.com/Hope2333/opencode-termux/releases)
