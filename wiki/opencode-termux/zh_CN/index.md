---
title: "opencode-termux"
lang: zh-CN
---

# opencode-termux

OpenCode on Termux/Android — 旗舰项目

## 简介

opencode-termux 将 [OpenCode](https://github.com/anomalyco/opencode) 引入 Termux/Android 环境，通过移植-复活管线产出零 glibc 依赖的原生 Android ELF。`opencode` 包名已成为稳定主线。

## 三条运行时线路

| 线路 | 包名 | 状态 | 运行时 |
|------|------|------|--------|
| **原生（主线）** | `opencode` | 稳定 | 纯 Bionic，零 glibc 依赖 |
| **glibc（附录）** | `opencode-glibc` | 维护 | glibc 封装 via bun-termux-loader |
| **压缩变体** | `opencode-compressed` | 后传 | UPX --best 压制原生 |

**二选一** — `opencode` 与 `opencode-glibc` 互斥不可共存。

## 快速安装

```bash
# 通过 hope2333 pacman 源（推荐）
pacman -S opencode          # 原生主线
pacman -S opencode-glibc    # glibc 附录
```

详见[安装指南](install.html)。

## 链接

- [GitHub](https://github.com/Hope2333/opencode-termux)
- [安装指南](install.html)
- [从源码构建](build.html)
- [架构说明](architecture.html)
- [最新发布](release/Push260903.html)
