---
title: "構建 opencode-termux"
lang: zh-TW
---

# 構建 opencode-termux

## Make 目標

```bash
make all VER=1.18.27 PKG=both        # 全家族构建
make batch VERS='1.18.15 1.18.27' PKG=deb  # 范围构建
make selfcheck                        # 验证环境
```

### 家族專屬目標

```bash
make family-glibc VER=1.18.27        # glibc 线路
make family-native VER=1.18.27       # 原生线路
make family-compressed VER=1.18.27   # 压缩线路
```

### 批量腳本

- `scripts/range-build.sh` — DRY=1 模式，磁盤護欄，失敗繼續
- `scripts/fleet-upx.sh` — 分佈式 UPX 壓制
- `scripts/sha-stage.sh` — SHA256SUMS 累積
- `scripts/push-stage.sh` — 幹跑 release 上傳

## 移植管線（原生）

1. **提取**：官方 Bun ELF
2. **檢測**：section 格式（自動）
3. **轉換**：模塊圖插入
4. **修補**：BUN_COMPILED.size + 偏移
5. **組裝**：最終 ELF 佈局
6. **復活**：運行時復活手術
7. **驗證**：自測運行

## 構建要求

- Bun、NDK、UPX
- make、bash、標準 coreutils
