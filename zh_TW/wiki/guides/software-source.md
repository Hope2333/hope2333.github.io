---
title: "軟件源指引"
lang: zh-TW
---

# 軟件源指引

Hope2333 軟件源的入口是 <https://hope2333.github.io/repo/>，當前提供 Termux（aarch64）軟件包，支持 pacman 與 apt 兩種客戶端。

## 一鍵配置（推薦）

在 Termux 中運行以下命令，即可自動完成源配置：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

腳本行爲：

- 自動檢測 Termux 環境（讀取 `$PREFIX`，未設置時回退到默認路徑）
- 寫入統一 `[hope2333]` 源並安裝 hope2333-mirrorlist 包（統一庫已直接收錄該包）；apt 客戶端寫入 hope2333-bootstrap.list 引導行
- 自動遷移舊版 `[hope2333-meta]` 引導節 / 舊 `[hope2333]` 塊 / 舊 apt 源配置
- 冪等：已配置過時跳過，不會重複寫入

腳本支持參數：`--install <包名>`（配置完成後直接安裝指定包）、`--help`（幫助與可用包列表）。例如一行完成配置 + 安裝：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

## 統一源 + mirrorlist 包（手動）

不想跑腳本的話，按客戶端手動配置統一源，再安裝 mirrorlist 包。

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

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

包安裝後鉤子會把手動節替換爲 `Include = /etc/pacman.d/hope2333-mirrorlist.conf` 一行（託管 conf 自帶 `[hope2333]` 節頭與 Server/SigLevel，經 Include 生效；pacman.conf 內保留同名節會雙重註冊丟 Server），此後源變更隨包升級生效。

apt 客戶端將引導行寫入 `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`：

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

```sh
apt update && apt install hope2333-mirrorlist
```

包內寫入 hope2333.list（5 行 flat，指向各倉 Release latest）。

> 舊 `deb .../repo/Termux/apt/ stable main` 行已失效（io 不再託管 apt 倉），請移除或替換爲引導行。已有舊版 `[hope2333-meta]` 引導節或舊 `[hope2333]` pacman 塊請整體替換爲統一節，勿追加（重複註冊會報 database already registered）；或直接重跑 install.sh 自動遷移。

## 手動配置（不裝 mirrorlist 包）

前往 [/repo/Termux/](https://hope2333.github.io/repo/Termux/) 查看完整說明。pacman 客戶端推薦按 mirrorlist 包內的統一寫法（單節多 Server，庫存優先、頁面兜底）：

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

mirrorlist 包即該節的持久化文件（`/etc/pacman.d/hope2333-mirrorlist.conf`），隨包更新；手動寫入等價於固定快照。

apt 客戶端使用 flat 源，將以下 5 行寫入 `$PREFIX/etc/apt/sources.list.d/hope2333.list`：

```text
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codegraph-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/opencode-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/MiMoCode-Termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/freebuff-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codebuff-termux/releases/latest/download/ ./
```

Packages 已在各倉 release 提供，flat 行可直接使用。

## 常用用法

配置完成後，pacman 客戶端的常用命令：

```sh
pacman -Sy              # 刷新软件源
pacman -Sy <包名>       # 安装软件包（同时刷新源）
pacman -Syu             # 刷新源并升级全部软件包
pacman -Ss <关键词>     # 搜索软件包
pacman -R <包名>        # 卸载软件包
```

apt 客戶端的常用命令：

```sh
apt update              # 刷新软件源
apt install <包名>      # 安装软件包
apt upgrade             # 升级全部软件包
apt search <关键词>     # 搜索软件包
```

日常升級見 [更新指引](update.md)。

## Roadmap

未來將引入簽名校驗（repo-add -s / Release 簽名），當前 v1 無簽名。
