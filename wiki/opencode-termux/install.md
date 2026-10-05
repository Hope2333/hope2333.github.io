---
title: "Install opencode-termux"
lang: en
---

# Install opencode-termux

## Via the hope2333 pacman source (recommended)

One unified source named `[hope2333]`: per-repo GitHub release CDN servers are tried first, this Pages site is the fallback. The source carries the latest packages of every feed repo (single-version snapshot).

### Bootstrap (first time only)

Install the managed mirrorlist package (fixed, tag-less URL):

```bash
pacman -U https://github.com/Hope2333/hope2333.github.io/releases/latest/download/hope2333-mirrorlist-latest-1-any.pkg.tar.xz
```

This writes `/etc/pacman.d/hope2333-mirrorlist.conf` and includes it from `/etc/pacman.conf`.

### Install families

```bash
# v2 native mainline (recommended — zero glibc deps, Android API >= 28)
pacman -S opencode

# v1 native mainline (coexists with v2)
pacman -S opencode1

# Appendix / compressed families (not in the Push261005 raw batch):
pacman -S opencode-wrapper        # v2 wrapper appendix
pacman -S opencode1-wrapper       # v1 wrapper appendix (glibc payload)
pacman -S opencode1-compressed    # v1 compressed (UPX, .pkg.tar.gz)
```

Legacy names `opencode-glibc` / `opencode-compressed` are retired and no longer served by the `[hope2333]` db — switch to `opencode-wrapper` / `opencode1-compressed` respectively.

## Via apt flat index

Per-repo flat indexes ride the latest release assets:

- opencode-termux: <https://github.com/Hope2333/opencode-termux/releases/download/Push260912/Packages.gz> — **pinned**: since Push261005 releases no longer ship `Packages.gz` (`latest/download` → 404), so the flat apt index is pinned to the newest tag that still ships it; the mirrorlist deb's `hope2333.list` carries the same pinned URL. Un-pin once releases ship the index again.

## Manual install

### Native (opencode / opencode1)

```bash
pacman -U opencode-<ver>-<rel>-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### Wrapper (opencode-wrapper / opencode1-wrapper)

```bash
pacman -U opencode-wrapper-<ver>-<pkgrel>-aarch64.pkg.tar.xz
dpkg -i opencode-wrapper_<ver>_aarch64.deb
```

### Compressed (opencode1-compressed) — UPX-packed, `.pkg.tar.gz`

```bash
pacman -U opencode1-compressed-<ver>-<pkgrel>-aarch64.pkg.tar.gz
dpkg -i opencode1-compressed_<ver>_aarch64.deb
```

### Standalone (opencode-glibc-standalone) — retired, no longer provided

> **No longer provided.** `opencode-glibc-standalone` is retired and is no longer published to the repository or releases; its install instructions are withdrawn. Use mainline `opencode` (native) or `opencode-wrapper` instead.

## Mutual Exclusion

Within one generation (v1 or v2), native / wrapper / compressed are mutually exclusive — pick ONE. Across generations, v1 (`opencode1*`) and v2 (`opencode*`) coexist; `*-standalone` is the coexistence exception.

## Switching Providers

Install the new provider — dpkg/pacman will automatically replace the conflicting one.

## Requirements

- Android API >= 28
- Termux (all families; the native families need no Termux `glibc` packages)
