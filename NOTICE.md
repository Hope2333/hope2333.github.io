# NOTICE — pacman 叠影事故公告（2026-10-04）

2026-09 下旬至 10 月初，经旧版 init/install 脚本配置本软件源的部分 Termux 机器，其 `pacman.conf` 被写入 `RootDir = /data/data/com.termux/files`。该配置与绝对路径包叠加后，包文件被装入 `/data/data/com.termux/files/data/data/com.termux/files/usr/...`（叠影目录），导致 pacman 安装的程序「装完即失效」。对此我们深表歉意。

**症状自检**：存在叠影目录 `/data/data/com.termux/files/data/`；或 `pacman -Ql <包名>` 列出的文件在磁盘上缺失（典型表现为 opencode 等程序无法启动）。

**一键修复**：

```sh
bash <(curl -sL https://github.com/Hope2333/opencode-termux/releases/download/EarlyEmergencyRelease0/init-pacmanV00fix20.sh)
```

脚本自动完成：注释 RootDir 回落默认 → 重装受影响包归位 → 校验落点 → 经你确认后清理叠影目录（非交互模式只报告）。

**自动检测**：此前通过 init 脚本安装本仓库的机器，hope2333-mirrorlist 包更新时将自动静默检测该病灶；一旦检出，会在安装输出中打印上述修复命令（无问题零输出）。

**预防**：包生成器已加入绝对路径断言门（零相对 `usr/` 成员方可出包），install.sh 的 RootDir 写入逻辑已同步纠正。
