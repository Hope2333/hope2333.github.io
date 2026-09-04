---
title: "Install opencode-termux"
lang: en
---

# Install opencode-termux

## Via hope2333 pacman source

```bash
# Add the source (first time only)
# See: https://hope2333.github.io/guides/software-source.html

# Native (recommended — zero glibc deps)
pacman -S opencode

# Glibc (appendix — requires glibc-repo)
pacman -S opencode-glibc
```

## Manual install

### Native (opencode)

```bash
# pacman
pacman -U opencode-<ver>-1-aarch64.pkg.tar.xz

# deb
dpkg -i opencode_<ver>_aarch64.deb
```

### Glibc (opencode-glibc)

```bash
# pacman
pacman -U opencode-glibc-<ver>-1-aarch64.pkg.tar.xz

# deb
dpkg -i opencode-glibc_<ver>_aarch64.deb
```

## Package Mutual Exclusion

```
opencode (native)  ↔  opencode-glibc  →  mutually exclusive, pick one
opencode (native)  +  opencode-glibc-standalone  →  can coexist
```

| Package A | Package B | Coexist? |
|-----------|-----------|----------|
| opencode | opencode-glibc | No |
| opencode | opencode-glibc-standalone | Yes |
| opencode-glibc | opencode-glibc-standalone | No (standalone provides opencode-glibc virtual) |

## Switching Providers

Install the new provider — dpkg/pacman will automatically replace the conflicting one.

## Requirements

- Android API >= 28
- Termux (native line) or glibc-repo (glibc line)
