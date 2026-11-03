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

> **最新批次（Push261103）**：v2 **2.0.32–2.2.5**（12 版）与 v1 **1.18.33–1.19.4**（8 版）native 全量发布（deb + pacman，共 40 包）— 一次补齐区间内每个已验收版本；2.2.x 走 opentui 0.7.0→0.8.0，2.2.2 上游删除 pty、2.2.3 以 `@opencode/pty` 回归；全部版本在 Android 9 / kernel 3.18.140 实测 TUI 可用。详见 [Push261103 发布页](release/Push261103.md)。

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
