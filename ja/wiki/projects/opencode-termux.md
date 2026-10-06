---
title: "opencode-termux"
lang: ja
---

# opencode-termux

> OpenCode on Termux/Android、旗艦プロジェクト

## 概要

OpenCode on Termux/Android。Hope2333 の旗艦プロジェクトです。OpenCode を Termux/Android 環境で動作させるもので、本サイト収録プロジェクトの中核にあたります。

## インストール

このプロジェクトは hope2333 ソフトウェアソース（pacman、統一ソース名 `[hope2333]`：各リポジトリの release ライブラリを優先し、本サイトへフォールバック）に収録されているため、次のように直接インストールするのがおすすめです：

```bash
# ネイティブメインライン（推奨）
pacman -S opencode

# glibc 付録（自己完結型の複合パッケージ、bin-only）
pacman -S opencode-glibc

# 圧縮バリアント（UPX、crhandler shim 同梱）
pacman -S opencode-compressed
```

詳細は [Wiki インストールガイド](/wiki/opencode-termux/install.md) を参照してください。

## リンク

- **Wiki**：[/wiki/opencode-termux/](/wiki/opencode-termux/)
- GitHub リポジトリ：<https://github.com/Hope2333/opencode-termux>
- リリース一覧（タグ固定なし）：<https://github.com/Hope2333/opencode-termux/releases>
