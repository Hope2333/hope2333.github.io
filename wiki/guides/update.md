# 更新指引

## 日常更新

pacman 客户端用一条命令完成刷新源与升级：

```sh
pacman -Syu
```

建议定期执行，保持软件包为最新版本。

## Rolling Push tag 机制

本站软件源采用 rolling Push tag 机制：新版本直接追加到既有 tag 上，不另开新 tag。因此无需关心版本号变化，`pacman -Syu` 拉到的就是当前最新构建。

## 源同步

软件源内容由 site-rebuild 流程触发同步，仓库更新后会自动反映到源中。
