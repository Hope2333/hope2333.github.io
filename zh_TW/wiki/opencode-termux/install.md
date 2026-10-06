---
title: "安裝 opencode-termux"
lang: zh-TW
---

# 安裝 opencode-termux

## 通過 hope2333 pacman 源（推薦）

統一源名 `[hope2333]`：各倉 GitHub release CDN 庫存優先，本站（Pages）回退。源內收錄各倉最新版軟件包（僅緩存一個版本號）。

### 引導（僅首次）

安裝託管 mirrorlist 包（固定無 tag 地址）：

```bash
pacman -U https://github.com/Hope2333/hope2333.github.io/releases/latest/download/hope2333-mirrorlist-latest-1-any.pkg.tar.xz
```

該包會寫入 `/etc/pacman.d/hope2333-mirrorlist.conf` 並在 `/etc/pacman.conf` 中 Include。

### 安裝家族

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

舊名 `opencode-glibc` / `opencode-compressed` 已退役，`[hope2333]` 庫不再提供——分別改用 `opencode-wrapper` / `opencode1-compressed`。

## 通過 apt flat 索引

各倉 flat 索引隨最新 release 資產分發：

- opencode-termux：<https://github.com/Hope2333/opencode-termux/releases/download/Push260912/Packages.gz> — **已釘版**：自 Push261005 起 release 不再隨附 `Packages.gz`（`latest/download` → 404），故 flat apt 索引釘在仍附帶索引的最新 tag；mirrorlist deb 的 `hope2333.list` 使用同一釘定 URL。待 release 恢復隨附索引後解除釘版。

## 手動安裝

### 原生（opencode / opencode1）

```bash
pacman -U opencode-<ver>-<rel>-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### wrapper（opencode-wrapper / opencode1-wrapper）

```bash
pacman -U opencode-wrapper-<ver>-<pkgrel>-aarch64.pkg.tar.xz
dpkg -i opencode-wrapper_<ver>_aarch64.deb
```

### 壓縮（opencode1-compressed）— UPX 壓制，`.pkg.tar.gz`

```bash
pacman -U opencode1-compressed-<ver>-<pkgrel>-aarch64.pkg.tar.gz
dpkg -i opencode1-compressed_<ver>_aarch64.deb
```

### standalone（opencode-glibc-standalone）— 已退役，不再提供

> **不再提供**：`opencode-glibc-standalone` 已退役，不再隨倉庫/release 發佈，安裝指引隨之撤除。需要回退能力請改用主線 `opencode`（native）或 `opencode-wrapper`。

## 互斥規則

同代（v1 或 v2）內 native / wrapper / compressed 互斥，三選一；跨代 v1（`opencode1*`）與 v2（`opencode*`）可共存；`*-standalone` 爲共存例外。

## 切換 provider

安裝新 provider 即可，dpkg/pacman 會自動替換衝突的舊包。

## 要求

- Android API >= 28
- Termux（全部家族；native 家族無需 Termux `glibc` 系包）
