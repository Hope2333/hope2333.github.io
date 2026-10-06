---
title: "インストールガイド"
lang: ja
---

# インストールガイド

各プロジェクトのインストール方法は、hope2333 ソフトウェアソースに収録されているかどうかで異なります。

## ソフトウェアソースの設定

インストールの前に、hope2333 ソフトウェアソースを設定する必要があります。おすすめはワンクリックスクリプト（旧設定を自動移行）です：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

または、ワンライナーで設定とインストールを一度に行うこともできます（`--install <パッケージ名>`。利用可能なパッケージ一覧はスクリプトの `--help` を参照）：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

あるいは、統一ソースと mirrorlist パッケージを手動で設定します。

**pacman クライアント**は統一セクションを `$PREFIX/etc/pacman.conf` に追記します：

```ini
[hope2333]
Server = https://github.com/Hope2333/codegraph-termux/releases/latest/download/
Server = https://github.com/Hope2333/opencode-termux/releases/latest/download/
Server = https://github.com/Hope2333/MiMoCode-Termux/releases/download/Push260829/
Server = https://github.com/Hope2333/freebuff-termux/releases/latest/download/
Server = https://github.com/Hope2333/codebuff-termux/releases/latest/download/
Server = https://hope2333.github.io/repo/Termux/pacman/
SigLevel = Optional TrustAll
```

続けて mirrorlist パッケージをインストールします：

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

パッケージインストール後のフックが、手動セクションを `Include = /etc/pacman.d/hope2333-mirrorlist.conf` の 1 行に置き換えます（管理対象の conf 自体に `[hope2333]` セクションヘッダと Server/SigLevel が含まれており、Include 経由で有効になります。pacman.conf 側に同名セクションを残すと二重登録になり Server が失われます）。以降のソース変更は、パッケージのアップグレードに伴って自動的に反映されます。

**apt クライアント**はブートストラップ行を `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list` に書き込みます：

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

続けて mirrorlist パッケージをインストールします：

```sh
apt update && apt install hope2333-mirrorlist
```

パッケージには hope2333.list が書き込まれます（各リポジトリの Release latest を指す 5 行の flat 形式）。

> 旧 `deb .../repo/Termux/apt/ stable main` 行は無効になりました（io は apt リポジトリをホストしていません）。削除するか、ブートストラップ行に置き換えてください。旧 `[hope2333-meta]` ブートストラップセクションや旧 `[hope2333]` pacman ブロックがある場合は、追記せずに統一セクションへ丸ごと置き換えてください（重複登録すると database already registered エラーになります）。または、install.sh を再実行して自動移行しても構いません。

## ソース収録済みプロジェクト（pacman）

収録済みのプロジェクトは pacman でのインストールを優先してください。codegraph を例にすると：

```sh
pacman -Sy codegraph
```

ワンクリックスクリプトで設定＋インストールを一気に済ませることもできます：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install codegraph
```

`-Sy` はソースを先に更新してからインストールするため、常に最新版を取得できます。今後もさらにリポジトリが順次ソースに収録される予定です。

## 未収録プロジェクト（GitHub から手動インストール）

まだソースに収録されていないプロジェクトは、対応する GitHub リポジトリから入手し、インストール方法はリポジトリの README を参照してください。各プロジェクトのリポジトリリンクは [プロジェクト索引](../index.md) を参照してください。

## インストールの確認

インストール完了後、`--version` 引数で確認できます。バージョン番号が正常に出力されればインストール成功です。
