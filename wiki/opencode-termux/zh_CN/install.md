---
title: "安装 opencode-termux"
lang: zh-CN
---

# 安装 opencode-termux

## 通过 hope2333 pacman 源

```bash
# 添加源（首次）
# 见：https://hope2333.github.io/guides/software-source.html

# 原生（推荐，零 glibc 依赖）
pacman -S opencode

# glibc（附录，需 glibc-repo）
pacman -S opencode-glibc
```

## 手动安装

### 原生（opencode）

```bash
pacman -U opencode-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### glibc（opencode-glibc）

```bash
pacman -U opencode-glibc-<ver>-1-aarch64.pkg.tar.xz
dpkg -i opencode-glibc_<ver>_aarch64.deb
```

## 互斥矩阵

```
opencode (原生)  ↔  opencode-glibc  →  互斥，二选一
opencode (原生)  +  opencode-glibc-standalone  →  可共存
```

## 切换 provider

安装新 provider 即可，dpkg/pacman 会自动替换冲突的旧包。

## 要求

- Android API >= 28
- Termux（原生线路）或 glibc-repo（glibc 线路）
