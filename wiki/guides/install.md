# 安装指引

各项目的安装方式取决于是否已进入 hope2333 软件源。

## 配置软件源

安装前需先配置 hope2333 软件源。推荐一键脚本（自动迁移旧配置）：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

或一行命令直接配置并安装（`--install <包名>`，可用包列表见脚本 `--help`）：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

或手动配置统一源 + mirrorlist 包。

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

再安装 mirrorlist 包：

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

包安装后钩子会把该节收敛为 `节头 + Include = /etc/pacman.d/hope2333-mirrorlist.conf`（Server/SigLevel 移入包内托管 conf），此后源变更随包升级生效。

apt 客户端将引导行写入 `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`：

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

再安装 mirrorlist 包：

```sh
apt update && apt install hope2333-mirrorlist
```

包内写入 hope2333.list（5 行 flat，指向各仓 Release latest）。

> 旧 `deb .../repo/Termux/apt/ stable main` 行已失效（io 不再托管 apt 仓），请移除或替换为引导行。已有旧版 `[hope2333-meta]` 引导节或旧 `[hope2333]` pacman 块请整体替换为统一节，勿追加（重复注册会报 database already registered）；或直接重跑 install.sh 自动迁移。

## 已入源项目（pacman）

已入源的项目优先用 pacman 安装，以 codegraph 为例：

```sh
pacman -Sy codegraph
```

也可用一键脚本一步到位（配置 + 安装）：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install codegraph
```

`-Sy` 会先刷新软件源再安装，确保拿到最新版本。更多仓库将陆续入源。

## 未入源项目（GitHub 手动安装）

尚未入源的项目，请前往对应项目的 GitHub 仓库获取，安装方式见仓库 README。各项目的仓库链接见 [项目索引](../index.html)。

## 验证安装

安装完成后，可通过 `--version` 参数验证，能正常输出版本号即安装成功。
