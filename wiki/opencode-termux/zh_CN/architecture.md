---
title: "架构说明"
lang: zh-CN
---

# 架构说明

## 移植管线

核心创新：将 OpenCode 的 JavaScript 模块图植入官方 Android Bun ELF，再执行「复活手术」产出单个 Bionic 可执行文件。

```
官方 Bun ELF → 提取 → 模块图插入 → 修补 → 组装 → 复活 → 可用二进制
```

## Seccomp SIGSYS Shim

双层保护：
- **Handler**：内联 syscall 拦截 + DT_NEEDED[0] interposer
- **PLT interposer**：捕获子进程 syscall

## TUI（libopentui.so）

自构建 bionic `libopentui.so`（NDK 编译），通过 `swap_tui.py` 等长替换植入。

## 原生 Watcher

`tools/watcher/` 提供独立文件监控守护进程：
- `watcher.c` — NDK inotify 递归监控
- `shim.js` — 插件侧接口
- E2E：三种事件类型 <100ms，自愈 ≤612ms

## 包格式

- `bin/opencode` 为真实可执行 ELF（无 bash 包装器）
- 三包互斥：opencode ↔ opencode-glibc ↔ opencode-compressed
