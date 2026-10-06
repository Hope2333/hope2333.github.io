---
title: "ソフトウェアソースガイド"
lang: ja
---

# ソフトウェアソースガイド

Hope2333 ソフトウェアソースの入口は <https://hope2333.github.io/repo/> です。現在は Termux（aarch64）向けパッケージを提供しており、pacman と apt の両クライアントに対応しています。

## ワンクリック設定（推奨）

Termux で以下のコマンドを実行するだけで、ソース設定を自動的に完了できます：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

スクリプトの動作：

- Termux 環境を自動検出（`$PREFIX` を読み取り、未設定時はデフォルトパスへフォールバック）
- 統一 `[hope2333]` ソースを書き込み、hope2333-mirrorlist パッケージをインストール（統一ライブラリに直接収録済み）；apt クライアントには hope2333-bootstrap.list のブートストラップ行を書き込み
- 旧 `[hope2333-meta]` ブートストラップセクション／旧 `[hope2333]` ブロック／旧 apt ソース設定を自動移行
- 冪等：設定済みならスキップし、重複書き込みしません

スクリプトは引数に対応しています：`--install <パッケージ名>`（設定完了後に指定パッケージを直接インストール）、`--help`（ヘルプと利用可能なパッケージ一覧）。たとえばワンライナーで設定＋インストールを一度に完了：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

## 統一ソース + mirrorlist パッケージ（手動）

スクリプトを実行したくない場合は、クライアントごとに統一ソースを手動設定し、その後 mirrorlist パッケージをインストールします。

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

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

パッケージインストール後のフックが、手動セクションを `Include = /etc/pacman.d/hope2333-mirrorlist.conf` の 1 行に置き換えます（管理対象の conf 自体に `[hope2333]` セクションヘッダと Server/SigLevel が含まれており、Include 経由で有効になります。pacman.conf 側に同名セクションを残すと二重登録になり Server が失われます）。以降のソース変更は、パッケージのアップグレードに伴って自動的に反映されます。

**apt クライアント**はブートストラップ行を `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list` に書き込みます：

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

```sh
apt update && apt install hope2333-mirrorlist
```

パッケージには hope2333.list が書き込まれます（各リポジトリの Release latest を指す 5 行の flat 形式）。

> 旧 `deb .../repo/Termux/apt/ stable main` 行は無効になりました（io は apt リポジトリをホストしていません）。削除するか、ブートストラップ行に置き換えてください。旧 `[hope2333-meta]` ブートストラップセクションや旧 `[hope2333]` pacman ブロックがある場合は、追記せずに統一セクションへ丸ごと置き換えてください（重複登録すると database already registered エラーになります）。または、install.sh を再実行して自動移行しても構いません。

## 手動設定（mirrorlist パッケージを入れない）

[/repo/Termux/](https://hope2333.github.io/repo/Termux/) で完全な説明を確認してください。pacman クライアントは、mirrorlist パッケージ内と同じ統一的な書き方（1 セクション複数 Server、リポジトリのライブラリ優先・サイトへフォールバック）をおすすめします：

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

mirrorlist パッケージはこのセクションを永続化したファイル（`/etc/pacman.d/hope2333-mirrorlist.conf`）で、パッケージの更新に伴って更新されます。手動書き込みは固定スナップショットと同等です。

**apt クライアント**は flat ソースを使い、以下の 5 行を `$PREFIX/etc/apt/sources.list.d/hope2333.list` に書き込みます：

```text
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codegraph-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/opencode-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/MiMoCode-Termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/freebuff-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codebuff-termux/releases/latest/download/ ./
```

Packages は各リポジトリの release で提供されているため、flat 行をそのまま使えます。

## よく使うコマンド

設定完了後の、pacman クライアントのよく使うコマンド：

```sh
pacman -Sy              # ソースを更新
pacman -Sy <パッケージ名>       # パッケージをインストール（ソース更新も同時）
pacman -Syu             # ソースを更新して全パッケージをアップグレード
pacman -Ss <キーワード>     # パッケージを検索
pacman -R <パッケージ名>        # パッケージをアンインストール
```

apt クライアントのよく使うコマンド：

```sh
apt update              # ソースを更新
apt install <パッケージ名>      # パッケージをインストール
apt upgrade             # 全パッケージをアップグレード
apt search <キーワード>     # パッケージを検索
```

日常的なアップグレードは [アップデートガイド](update.md) を参照してください。

## Roadmap

将来的には署名検証（repo-add -s / Release 署名）を導入する予定です。現在の v1 は署名なしです。
