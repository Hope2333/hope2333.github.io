---
title: "Architecture"
lang: en
---

# Architecture

## Transplant Pipeline

The core innovation: graft OpenCode's JavaScript module graph into the official Android Bun ELF, then run a "revive surgery" to produce a single Bionic executable.

```
Official Bun ELF → Extract → Module graph insertion → Patch → Assemble → Revive → Working binary
```

Key insight: the original failure ("zero glibc is impossible") was caused by `assemble` never patching `BUN_COMPILED.size` in the `.bun` section. Fixed in the transplant pipeline.

## Seccomp SIGSYS Shim

Dual-layer protection:

- **Handler**: Inline syscall interception + DT_NEEDED[0] interposer
- **PLT interposer**: Catches syscalls from child processes

This ensures the binary can handle Android's seccomp restrictions gracefully.

## TUI (libopentui.so)

A self-built bionic `libopentui.so` (compiled with NDK) provides terminal UI rendering. Swapped into the binary via `tools/transplant/swap_tui.py` at equal length.

- W10a deep smoke test: 5/5 pass (real chat, resize, clean exit, 5min soak)
- RSS actually drops during idle (proven stable)

## Native Watcher

`tools/watcher/` provides a standalone file watching daemon:
- `watcher.c` — NDK inotify recursive watching
- `shim.js` — Plugin-side interface
- E2E: all three event types <100ms, self-heal ≤612ms

## Package Format

- `bin/opencode` is a real executable ELF (no bash wrapper)
- Three-way mutual exclusion: opencode ↔ opencode-glibc ↔ opencode-compressed
- Standalone variant: `bin/opencode-glibc` entry, coexists with native
