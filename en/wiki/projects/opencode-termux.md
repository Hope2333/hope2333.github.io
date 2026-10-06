---
title: "opencode-termux"
lang: en
---

# opencode-termux

> OpenCode on Termux/Android, the flagship project

## Overview

OpenCode on Termux/Android — the flagship project of Hope2333. This project runs OpenCode in the Termux/Android environment and is the most central of all projects listed on this site.

## Installation

This project is available in the hope2333 repository (pacman, unified source name `[hope2333]`: per-repo release libraries take priority, this site as fallback). The recommended way is to install directly:

```bash
# Native mainline (recommended)
pacman -S opencode

# glibc appendix (self-contained composite, bin-only)
pacman -S opencode-glibc

# Compressed variant (UPX, with crhandler shim)
pacman -S opencode-compressed
```

See the [wiki installation guide](/wiki/opencode-termux/install.md) for details.

## Links

- **Wiki**: [/wiki/opencode-termux/](/wiki/opencode-termux/)
- GitHub repository: <https://github.com/Hope2333/opencode-termux>
- Release list (tags not pinned): <https://github.com/Hope2333/opencode-termux/releases>
