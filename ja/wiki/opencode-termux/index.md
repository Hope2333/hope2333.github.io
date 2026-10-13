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

> **最新バッチ（Push261013）**：全ファミリーバッチ — v2 2.0.23–2.0.27 + v1 1.18.35/1.19.0（新 1.19.0 マイナーライン含む）、native/compressed/wrapper 完全同梱（wrapper は deb のみ）、全て初リリース rel=1。v2 native の依存は上流版ごとにピン留め（opentui 0.5.14/16/17 + pty 0.2.0）。

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
