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
# Native mainline (recommended — zero glibc deps, Android API >= 28)
pacman -S opencode

# Glibc appendix (self-contained composite; no Termux glibc packages needed)
pacman -S opencode-glibc

# Compressed variant (UPX-packed; ships usr/lib/opencode/libopencode-crhandler.so)
pacman -S opencode-compressed
```

## Via apt flat index

Per-repo flat indexes ride the latest release assets:

- opencode-termux: <https://github.com/Hope2333/opencode-termux/releases/latest/download/Packages.gz> (40 entries: 13 native + 13 compressed + 13 glibc + 1 standalone)

## Manual install

### Native (opencode)

```bash
pacman -U opencode-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### Glibc (opencode-glibc) — bin-only, self-contained

```bash
pacman -U opencode-glibc-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode-glibc_<ver>_aarch64.deb
```

### Compressed (opencode-compressed) — gzip fast-wrap, always ships the crhandler shim

```bash
pacman -U opencode-compressed-<ver>-1-aarch64.pkg.tar.gz
dpkg -i opencode-compressed_<ver>_aarch64.deb
```

### Standalone (opencode-glibc-standalone) — frozen rollback, coexists with opencode

```bash
pacman -U opencode-glibc-standalone-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode-glibc-standalone_<ver>_aarch64.deb
```

## Mutual Exclusion

| Package A | Package B | Coexist? |
|-----------|-----------|----------|
| opencode | opencode-glibc | No |
| opencode | opencode-compressed | No |
| opencode-glibc | opencode-compressed | No |
| opencode | opencode-glibc-standalone | Yes |

## Switching Providers

Install the new provider — dpkg/pacman will automatically replace the conflicting one.

## Requirements

- Android API >= 28
- Termux (all families; the glibc family no longer requires the Termux `glibc` / `ca-certificates-glibc` packages)
