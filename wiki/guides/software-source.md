# 软件源指引

Hope2333 软件源的入口是 <https://hope2333.github.io/repo/>，当前提供 Termux（aarch64）软件包，支持 pacman 与 apt 两种客户端。

## 一键配置（推荐）

在 Termux 中运行以下命令，即可自动完成源配置：

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

脚本行为：

- 自动检测 Termux 环境（读取 `$PREFIX`，未设置时回退到默认路径）
- 检测包管理器：pacman 直接写入 hope2333 源；plain Termux（apt）仅打印迁移指引，不会自动迁移
- 幂等：已配置过 hope2333 源时跳过，不会重复写入

## 手动配置

不想跑脚本的话，前往 [/repo/Termux/](https://hope2333.github.io/repo/Termux/) 查看 pacman 与 apt 两种客户端的配置说明，按页面提示操作即可。

其中 pacman 客户端的配置块会追加到 `$PREFIX/etc/pacman.conf`：

```ini
[hope2333]
Server = https://hope2333.github.io/repo/Termux/pacman/
SigLevel = Optional TrustAll
```

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

## Roadmap

未来将引入签名校验（repo-add -s / Release 签名），当前 v1 无签名。
