# 软件源指引

Hope2333 软件源的入口是 <https://hope2333.github.io/repo/>，当前提供 Termux（aarch64）软件包，支持 pacman 与 apt 两种客户端。

## 一键配置（推荐）

在 Termux 中运行以下命令，即可自动完成源配置：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

脚本行为：

- 自动检测 Termux 环境（读取 `$PREFIX`，未设置时回退到默认路径）
- 写入统一 `[hope2333]` 源并安装 hope2333-mirrorlist 包（统一库已直接收录该包）；apt 客户端写入 hope2333-bootstrap.list 引导行
- 自动迁移旧版 `[hope2333-meta]` 引导节 / 旧 `[hope2333]` 块 / 旧 apt 源配置
- 幂等：已配置过时跳过，不会重复写入

脚本支持参数：`--install <包名>`（配置完成后直接安装指定包）、`--help`（帮助与可用包列表）。例如一行完成配置 + 安装：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

## 统一源 + mirrorlist 包（手动）

不想跑脚本的话，按客户端手动配置统一源，再安装 mirrorlist 包。

pacman 客户端将统一节追加到 `$PREFIX/etc/pacman.conf`：

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

包安装后钩子会把手动节替换为 `Include = /etc/pacman.d/hope2333-mirrorlist.conf` 一行（托管 conf 自带 `[hope2333]` 节头与 Server/SigLevel，经 Include 生效；pacman.conf 内保留同名节会双重注册丢 Server），此后源变更随包升级生效。

apt 客户端将引导行写入 `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`：

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

```sh
apt update && apt install hope2333-mirrorlist
```

包内写入 hope2333.list（5 行 flat，指向各仓 Release latest）。

> 旧 `deb .../repo/Termux/apt/ stable main` 行已失效（io 不再托管 apt 仓），请移除或替换为引导行。已有旧版 `[hope2333-meta]` 引导节或旧 `[hope2333]` pacman 块请整体替换为统一节，勿追加（重复注册会报 database already registered）；或直接重跑 install.sh 自动迁移。

## 手动配置（不装 mirrorlist 包）

前往 [/repo/Termux/](https://hope2333.github.io/repo/Termux/) 查看完整说明。pacman 客户端推荐按 mirrorlist 包内的统一写法（单节多 Server，库存优先、页面兜底）：

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

mirrorlist 包即该节的持久化文件（`/etc/pacman.d/hope2333-mirrorlist.conf`），随包更新；手动写入等价于固定快照。

apt 客户端使用 flat 源，将以下 5 行写入 `$PREFIX/etc/apt/sources.list.d/hope2333.list`：

```text
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codegraph-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/opencode-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/MiMoCode-Termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/freebuff-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codebuff-termux/releases/latest/download/ ./
```

Packages 已在各仓 release 提供，flat 行可直接使用。

## 常用用法

配置完成后，pacman 客户端的常用命令：

```sh
pacman -Sy              # 刷新软件源
pacman -Sy <包名>       # 安装软件包（同时刷新源）
pacman -Syu             # 刷新源并升级全部软件包
pacman -Ss <关键词>     # 搜索软件包
pacman -R <包名>        # 卸载软件包
```

apt 客户端的常用命令：

```sh
apt update              # 刷新软件源
apt install <包名>      # 安装软件包
apt upgrade             # 升级全部软件包
apt search <关键词>     # 搜索软件包
```

日常升级见 [更新指引](update.html)。

## Roadmap

未来将引入签名校验（repo-add -s / Release 签名），当前 v1 无签名。
