---
title: "opencode-termux"
lang: zh-CN
---

# opencode-termux

OpenCode on Termux/Android — 旗舰项目

## 简介

opencode-termux 将 [OpenCode](https://github.com/anomalyco/opencode) 引入 Termux/Android 环境，通过移植-复活管线产出零 glibc 依赖的原生 Android ELF。`opencode` 包名已成为稳定主线。

## 五家族 × 两代矩阵

五个家族、两代并存（v1 与 v2 可同装）：

| 包名 | 代 | 状态 | 运行时 |
|------|----|------|--------|
| **原生（v2 主线）** | v2 | `opencode` | 稳定 — 纯 Bionic，零 glibc 依赖 |
| **wrapper（v2 附录）** | v2 | `opencode-wrapper` | bun-termux-loader 封装 |
| **原生（v1 主线）** | v1 | `opencode1` | 稳定 — 纯 Bionic，零 glibc 依赖 |
| **wrapper（v1 附录）** | v1 | `opencode1-wrapper` | glibc 运行时载荷 |
| **压缩（v1）** | v1 | `opencode1-compressed` | UPX 压制原生（`.pkg.tar.gz`） |

同代内 native / wrapper / compressed 三选一；跨代 v1（`opencode1*`）与 v2（`opencode*`）可共存。旧名 `opencode-glibc`、`opencode-compressed`、`opencode-glibc-standalone` 已退役，并从统一 `[hope2333]` 库中硬性剔除。

> **最新批次（Push261005，pkgrel `-90`）**：仅 native 家族 — fleet B 线重建代（NDK r27c、不 strip），raw 未压缩原包；compressed 族后续同一 tag 追加。

## 快速安装

```bash
# 通过 hope2333 pacman 源（推荐）
pacman -S opencode     # v2 原生主线
pacman -S opencode1    # v1 原生主线（与 v2 共存）
```

详见[安装指南](install.html)。

## 链接

- [GitHub](https://github.com/Hope2333/opencode-termux)
- [安装指南](install.html)
- [从源码构建](build.html)
- [架构说明](architecture.html)
- [发布列表（不钉 tag）](https://github.com/Hope2333/opencode-termux/releases)
