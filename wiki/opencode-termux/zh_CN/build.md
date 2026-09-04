---
title: "构建 opencode-termux"
lang: zh-CN
---

# 构建 opencode-termux

## Make 目标

```bash
make all VER=1.18.27 PKG=both        # 全家族构建
make batch VERS='1.18.15 1.18.27' PKG=deb  # 范围构建
make selfcheck                        # 验证环境
```

### 家族专属目标

```bash
make family-glibc VER=1.18.27        # glibc 线路
make family-native VER=1.18.27       # 原生线路
make family-compressed VER=1.18.27   # 压缩线路
```

### 批量脚本

- `scripts/range-build.sh` — DRY=1 模式，磁盘护栏，失败继续
- `scripts/fleet-upx.sh` — 分布式 UPX 压制
- `scripts/sha-stage.sh` — SHA256SUMS 累积
- `scripts/push-stage.sh` — 干跑 release 上传

## 移植管线（原生）

1. **提取**：官方 Bun ELF
2. **检测**：section 格式（自动）
3. **转换**：模块图插入
4. **修补**：BUN_COMPILED.size + 偏移
5. **组装**：最终 ELF 布局
6. **复活**：运行时复活手术
7. **验证**：自测运行

## 构建要求

- Bun、NDK、UPX
- make、bash、标准 coreutils
