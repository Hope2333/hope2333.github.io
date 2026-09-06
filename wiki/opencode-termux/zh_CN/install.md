---
title: "安装 opencode-termux"
lang: zh-CN
---

# 安装 opencode-termux

## 通过 hope2333 pacman 源（推荐）

统一源名 `[hope2333]`：各仓 GitHub release CDN 库存优先，本站（Pages）回退。源内收录各仓最新版软件包（仅缓存一个版本号）。

### 引导（仅首次）

安装托管 mirrorlist 包（固定无 tag 地址）：

```bash
pacman -U https://github.com/Hope2333/hope2333.github.io/releases/latest/download/hope2333-mirrorlist-latest-1-any.pkg.tar.xz
```

该包会写入 `/etc/pacman.d/hope2333-mirrorlist.conf` 并在 `/etc/pacman.conf` 中 Include。

### 安装家族

```bash
# 原生主线（推荐，零 glibc 依赖，Android API >= 28）
pacman -S opencode

# glibc 附录（自包含复合体，无需 Termux glibc 系包）
pacman -S opencode-glibc

# 压缩变体（UPX 压制，自带 usr/lib/opencode/libopencode-crhandler.so）
pacman -S opencode-compressed
```

## 通过 apt flat 索引

各仓 flat 索引随最新 release 资产分发：

- opencode-termux：<https://github.com/Hope2333/opencode-termux/releases/latest/download/Packages.gz>（40 条：13 原生 + 13 压缩 + 13 glibc + 1 standalone）

## 手动安装

### 原生（opencode）

```bash
pacman -U opencode-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### glibc（opencode-glibc）— bin-only、自包含

```bash
pacman -U opencode-glibc-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode-glibc_<ver>_aarch64.deb
```

### 压缩（opencode-compressed）— gzip 快速包装，恒带 crhandler shim

```bash
pacman -U opencode-compressed-<ver>-1-aarch64.pkg.tar.gz
dpkg -i opencode-compressed_<ver>_aarch64.deb
```

### standalone（opencode-glibc-standalone）— 冻结回退，可与 opencode 共存

```bash
pacman -U opencode-glibc-standalone-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode-glibc-standalone_<ver>_aarch64.deb
```

## 互斥矩阵

| 包 A | 包 B | 可共存？ |
|------|------|----------|
| opencode | opencode-glibc | 否 |
| opencode | opencode-compressed | 否 |
| opencode-glibc | opencode-compressed | 否 |
| opencode | opencode-glibc-standalone | 是 |

## 切换 provider

安装新 provider 即可，dpkg/pacman 会自动替换冲突的旧包。

## 要求

- Android API >= 28
- Termux（全部家族；glibc 家族已不再需要 Termux `glibc` / `ca-certificates-glibc` 包）
