---
title: "opencode-termux"
lang: ja
---

# opencode-termux

OpenCode on Termux/Android — 旗艦プロジェクト。

## 概要

opencode-termux は、[OpenCode](https://github.com/anomalyco/opencode) をネイティブ Bionic ランタイム経由で Termux/Android に持ち込みます。本プロジェクトは transplant-revive パイプラインによってゼロ glibc の単一 Android ELF を生成し、`opencode` パッケージ名で正式リリースとして公開しています。

## パッケージファミリー

2 世代 × 5 ファミリーで、並べてインストール可能です（v1 と v2 は共存できます）：

| パッケージ | 世代 | 状態 | ランタイム |
|---------|-----|--------|---------|
| **Native（メインライン）** | v2 | `opencode` | 安定 — 純 Bionic、glibc 依存ゼロ |
| **Wrapper（付録）** | v2 | `opencode-wrapper` | Bun-termux-loader ラッパー |
| **Native（v1 メインライン）** | v1 | `opencode1` | 安定 — 純 Bionic、glibc 依存ゼロ |
| **Wrapper（v1 付録）** | v1 | `opencode1-wrapper` | Glibc ランタイム payload |
| **Compressed（v1）** | v1 | `opencode1-compressed` | UPX 圧縮ネイティブ（`.pkg.tar.gz`） |

同一世代内では native / wrapper / compressed のうち**必ず 1 つだけ**を選びます。v1（`opencode1*`）と v2（`opencode*`）は共存可能です。旧名称 `opencode-glibc`、`opencode-compressed`、`opencode-glibc-standalone` は廃止され、統一 `[hope2333]` db からは削除（ハードドロップ）されています。

> **最新批次（Push261016）**：**#36 seccomp 修复**（native 补 crhandler interpose，Android 12 close_range 不再 SIGSYS，受影响版本已重打包）+ 新版本 v2 2.0.28–2.0.31 / v1 1.19.1–1.19.3 三族齐发（wrapper 仅 deb），84 资产，rel=1。

## クイックインストール

```bash
# hope2333 pacman ソース経由（推奨）
pacman -S opencode     # v2 native メインライン
pacman -S opencode1    # v1 native メインライン（v2 と共存）
```

詳細は [インストールガイド](install.md) を参照してください。

## リンク

- [GitHub](https://github.com/Hope2333/opencode-termux)
- [インストールガイド](install.md)
- [ソースからビルド](build.md)
- [アーキテクチャ](architecture.md)
- [リリース一覧（タグ固定なし）](https://github.com/Hope2333/opencode-termux/releases)
