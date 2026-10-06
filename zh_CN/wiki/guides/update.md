---
title: "更新指引"
lang: zh-CN
---

> [!NOTE]
> **说明**：本页为根路径 canonical 页的原文镜像；该页的独立简体中文译文尚未撰写。原文页：[/wiki/guides/update](/wiki/guides/update.md)。已完整中译的站点内容从 [中文 wiki 索引](/zh_CN/wiki/opencode-termux/) 进入。

# 更新指引

## 日常更新

pacman 客户端：

```sh
pacman -Syu
```

apt 客户端：

```sh
apt update && apt upgrade
```

`apt upgrade` 会连带升级 hope2333-mirrorlist（源列表随包更新）；pacman 客户端同理。建议定期执行，保持软件包为最新版本。

## 版本发布机制

各仓以 Push tag 形式发布（如 Push260906），`releases/latest/download` 始终指向最新正式批次；统一源与页面包由 site-rebuild 流程在发版后自动同步。因此无需关心 tag 名称，`pacman -Syu` / `apt upgrade` 拉到的就是当前最新构建。

## 源同步

软件源内容由 site-rebuild 流程触发同步，仓库更新后会自动反映到源中。
