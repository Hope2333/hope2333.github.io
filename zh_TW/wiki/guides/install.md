---
title: "安裝指引"
lang: zh-TW
---

# 安裝指引

各項目的安裝方式取決於是否已進入 hope2333 軟件源。

## 配置軟件源

安裝前需先配置 hope2333 軟件源。推薦一鍵腳本（自動遷移舊配置）：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

或一行命令直接配置並安裝（`--install <包名>`，可用包列表見腳本 `--help`）：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

或手動配置統一源 + mirrorlist 包。

pacman 客戶端將統一節追加到 `$PREFIX/etc/pacman.conf`：

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

再安裝 mirrorlist 包：

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

包安裝後鉤子會把手動節替換爲 `Include = /etc/pacman.d/hope2333-mirrorlist.conf` 一行（託管 conf 自帶 `[hope2333]` 節頭與 Server/SigLevel，經 Include 生效；pacman.conf 內保留同名節會雙重註冊丟 Server），此後源變更隨包升級生效。

apt 客戶端將引導行寫入 `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`：

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

再安裝 mirrorlist 包：

```sh
apt update && apt install hope2333-mirrorlist
```

包內寫入 hope2333.list（5 行 flat，指向各倉 Release latest）。

> 舊 `deb .../repo/Termux/apt/ stable main` 行已失效（io 不再託管 apt 倉），請移除或替換爲引導行。已有舊版 `[hope2333-meta]` 引導節或舊 `[hope2333]` pacman 塊請整體替換爲統一節，勿追加（重複註冊會報 database already registered）；或直接重跑 install.sh 自動遷移。

## 已入源項目（pacman）

已入源的項目優先用 pacman 安裝，以 codegraph 爲例：

```sh
pacman -Sy codegraph
```

也可用一鍵腳本一步到位（配置 + 安裝）：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install codegraph
```

`-Sy` 會先刷新軟件源再安裝，確保拿到最新版本。更多倉庫將陸續入源。

## 未入源項目（GitHub 手動安裝）

尚未入源的項目，請前往對應項目的 GitHub 倉庫獲取，安裝方式見倉庫 README。各項目的倉庫鏈接見 [項目索引](../index.md)。

## 驗證安裝

安裝完成後，可通過 `--version` 參數驗證，能正常輸出版本號即安裝成功。
