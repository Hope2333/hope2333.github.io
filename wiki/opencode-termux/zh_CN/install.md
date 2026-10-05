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
# v2 原生主线（推荐，零 glibc 依赖，Android API >= 28）
pacman -S opencode

# v1 原生主线（与 v2 共存）
pacman -S opencode1

# 附录 / 压缩家族（不在 Push261005 raw 批内）：
pacman -S opencode-wrapper        # v2 wrapper 附录
pacman -S opencode1-wrapper       # v1 wrapper 附录（glibc 载荷）
pacman -S opencode1-compressed    # v1 压缩变体（UPX，.pkg.tar.gz）
```

旧名 `opencode-glibc` / `opencode-compressed` 已退役，`[hope2333]` 库不再提供——分别改用 `opencode-wrapper` / `opencode1-compressed`。

## 通过 apt flat 索引

各仓 flat 索引随最新 release 资产分发：

- opencode-termux：<https://github.com/Hope2333/opencode-termux/releases/download/Push260912/Packages.gz> — **已钉版**：自 Push261005 起 release 不再随附 `Packages.gz`（`latest/download` → 404），故 flat apt 索引钉在仍附带索引的最新 tag；mirrorlist deb 的 `hope2333.list` 使用同一钉定 URL。待 release 恢复随附索引后解除钉版。

## 手动安装

### 原生（opencode / opencode1）

```bash
pacman -U opencode-<ver>-90-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### wrapper（opencode-wrapper / opencode1-wrapper）

```bash
pacman -U opencode-wrapper-<ver>-<pkgrel>-aarch64.pkg.tar.xz
dpkg -i opencode-wrapper_<ver>_aarch64.deb
```

### 压缩（opencode1-compressed）— UPX 压制，`.pkg.tar.gz`

```bash
pacman -U opencode1-compressed-<ver>-<pkgrel>-aarch64.pkg.tar.gz
dpkg -i opencode1-compressed_<ver>_aarch64.deb
```

### standalone（opencode-glibc-standalone）— 已退役，不再提供

> **不再提供**：`opencode-glibc-standalone` 已退役，不再随仓库/release 发布，安装指引随之撤除。需要回退能力请改用主线 `opencode`（native）或 `opencode-wrapper`。

## 互斥规则

同代（v1 或 v2）内 native / wrapper / compressed 互斥，三选一；跨代 v1（`opencode1*`）与 v2（`opencode*`）可共存；`*-standalone` 为共存例外。

## 切换 provider

安装新 provider 即可，dpkg/pacman 会自动替换冲突的旧包。

## 要求

- Android API >= 28
- Termux（全部家族；native 家族无需 Termux `glibc` 系包）
