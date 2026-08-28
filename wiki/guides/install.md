# 安装指引

各项目的安装方式取决于是否已进入 hope2333 软件源。

## 配置软件源

安装前需先将 hope2333 软件源加入客户端。pacman 客户端将以下配置块追加到 `$PREFIX/etc/pacman.conf`：

```ini
[hope2333]
Server = https://hope2333.github.io/repo/Termux/pacman/
Server = https://github.com/Hope2333/codegraph-termux/releases/latest/download/
Server = https://github.com/Hope2333/opencode-termux/releases/latest/download/
Server = https://github.com/Hope2333/MiMoCode-Termux/releases/latest/download/
Server = https://github.com/Hope2333/freebuff-termux/releases/latest/download/
Server = https://github.com/Hope2333/codebuff-termux/releases/latest/download/
SigLevel = Optional TrustAll
```

apt 客户端使用 flat 源，将以下 5 行写入 `$PREFIX/etc/apt/sources.list.d/hope2333.list`：

```text
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codegraph-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/opencode-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/MiMoCode-Termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/freebuff-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codebuff-termux/releases/latest/download/ ./
```

> 生效依赖各源仓 release 提供 Packages.gz（termux-asset-update v7.2），落地前 flat 行 404。

## 已入源项目（pacman）

已入源的项目优先用 pacman 安装，以 codegraph 为例：

```sh
pacman -Sy codegraph
```

`-Sy` 会先刷新软件源再安装，确保拿到最新版本。更多仓库将陆续入源。

## 未入源项目（GitHub 手动安装）

尚未入源的项目，请前往对应项目的 GitHub 仓库获取，安装方式见仓库 README。各项目的仓库链接见 [项目索引](../index.html)。

## 验证安装

安装完成后，可通过 `--version` 参数验证，能正常输出版本号即安装成功。
