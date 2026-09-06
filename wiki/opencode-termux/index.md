---
title: "opencode-termux"
lang: en
---

# opencode-termux

OpenCode on Termux/Android — flagship project.

## Overview

opencode-termux brings [OpenCode](https://github.com/anomalyco/opencode) to Termux/Android via a native Bionic runtime. The project produces a single zero-glibc Android ELF through a transplant-revive pipeline, shipped as formal releases under the `opencode` package name.

## Three Runtime Lines

| Line | Package | Status | Runtime |
|------|---------|--------|---------|
| **Native (mainline)** | `opencode` | Stable | Pure Bionic, zero glibc deps |
| **Glibc (appendix)** | `opencode-glibc` | Maintenance | glibc wrapper via bun-termux-loader |
| **Compressed** | `opencode-compressed` | Follow-up | UPX --best packed native |

**Pick ONE provider** — `opencode`, `opencode-glibc` and `opencode-compressed` are mutually exclusive (`opencode-glibc-standalone` coexists with `opencode`).

## Quick Install

```bash
# Via hope2333 pacman source (recommended)
pacman -S opencode              # native mainline
pacman -S opencode-glibc        # glibc appendix (bin-only, self-contained)
pacman -S opencode-compressed   # compressed variant (UPX + crhandler shim)
```

See [install guide](install.html) for details.

## Links

- [GitHub](https://github.com/Hope2333/opencode-termux)
- [Install guide](install.html)
- [Build from source](build.html)
- [Architecture](architecture.html)
- [Releases (no tag pin)](https://github.com/Hope2333/opencode-termux/releases)
