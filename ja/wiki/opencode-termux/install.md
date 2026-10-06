---
title: "opencode-termux のインストール"
lang: ja
---

# opencode-termux のインストール

## hope2333 pacman ソース経由（推奨）

統一ソース `[hope2333]` は 1 つだけです：各リポジトリの GitHub release CDN サーバを先に試行し、この Pages サイトがフォールバックになります。このソースには各フィードリポジトリの最新パッケージが収録されています（単一バージョンのスナップショット）。

### ブートストラップ（初回のみ）

管理対象の mirrorlist パッケージをインストールします（固定のタグなし URL）：

```bash
pacman -U https://github.com/Hope2333/hope2333.github.io/releases/latest/download/hope2333-mirrorlist-latest-1-any.pkg.tar.xz
```

これにより `/etc/pacman.d/hope2333-mirrorlist.conf` が書き込まれ、`/etc/pacman.conf` から Include されます。

### ファミリーのインストール

```bash
# v2 native メインライン（推奨 — glibc 依存ゼロ、Android API >= 28）
pacman -S opencode

# v1 native メインライン（v2 と共存）
pacman -S opencode1

# 付録／圧縮ファミリー（Push261005 の raw バッチには未収録）：
pacman -S opencode-wrapper        # v2 wrapper 付録
pacman -S opencode1-wrapper       # v1 wrapper 付録（glibc payload）
pacman -S opencode1-compressed    # v1 圧縮版（UPX、.pkg.tar.gz）
```

旧名称 `opencode-glibc` / `opencode-compressed` は廃止され、`[hope2333]` db では提供されなくなりました — それぞれ `opencode-wrapper` / `opencode1-compressed` に切り替えてください。

## apt flat インデックス経由

リポジトリごとの flat インデックスは最新 release のアセットに載っています：

- opencode-termux: <https://github.com/Hope2333/opencode-termux/releases/download/Push260912/Packages.gz> — **固定（pinned）**：Push261005 以降のリリースでは `Packages.gz` を同梱しなくなったため（`latest/download` → 404）、flat apt インデックスは同梱があった最後のタグに固定されています。mirrorlist deb の `hope2333.list` も同じ固定 URL を指します。リリースが再びインデックスを同梱するようになったら固定を解除してください。

## 手動インストール

### Native（opencode / opencode1）

```bash
pacman -U opencode-<ver>-<rel>-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### Wrapper（opencode-wrapper / opencode1-wrapper）

```bash
pacman -U opencode-wrapper-<ver>-<pkgrel>-aarch64.pkg.tar.xz
dpkg -i opencode-wrapper_<ver>_aarch64.deb
```

### Compressed（opencode1-compressed）— UPX 圧縮、`.pkg.tar.gz`

```bash
pacman -U opencode1-compressed-<ver>-<pkgrel>-aarch64.pkg.tar.gz
dpkg -i opencode1-compressed_<ver>_aarch64.deb
```

### Standalone（opencode-glibc-standalone）— 廃止、提供終了

> **提供は終了しました。** `opencode-glibc-standalone` は廃止され、リポジトリやリリースへの公開も停止しています。インストール手順も撤去されています。メインラインの `opencode`（native）または `opencode-wrapper` を使用してください。

## 相互排他

同一世代内（v1 または v2）では、native / wrapper / compressed は相互排他です — **必ず 1 つだけ**選んでください。世代をまたぐ場合は v1（`opencode1*`）と v2（`opencode*`）が共存できます。`*-standalone` のみ共存の例外です。

## プロバイダの切り替え

新しいプロバイダをインストールすれば、dpkg/pacman が競合する側を自動的に置き換えます。

## 要件

- Android API >= 28
- Termux（全ファミリー共通。native ファミリーは Termux の `glibc` パッケージを必要としません）
