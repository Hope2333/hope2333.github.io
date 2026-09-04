---
title: "Build opencode-termux"
lang: en
---

# Build opencode-termux

## Make Targets

```bash
make all VER=1.18.27 PKG=both        # Build all families for a version
make batch VERS='1.18.15 1.18.27' PKG=deb  # Build range
make selfcheck                        # Validate setup
```

### Family-specific targets

```bash
make family-glibc VER=1.18.27        # Glibc line only
make family-native VER=1.18.27       # Native line only
make family-compressed VER=1.18.27   # Compressed (UPX) only
```

### Batch scripts

- `scripts/range-build.sh` — DRY=1 mode, disk guardrail, continue-on-fail
- `scripts/fleet-upx.sh` — Distributed UPX compression
- `scripts/sha-stage.sh` — SHA256SUMS accumulation
- `scripts/push-stage.sh` — Dry-run release upload

## Transplant Pipeline (Native)

The native line uses a transplant-revive pipeline:

1. **Extract**: Base Bun ELF from official Android build
2. **Detect**: Section format (auto per Bun version)
3. **Convert**: Module graph insertion
4. **Patch**: BUN_COMPILED.size + offsets
5. **Assemble**: Final ELF layout
6. **Revive**: Runtime resurrection surgery
7. **Verify**: Self-test run

After transplant, a seccomp-harden step adds the SIGSYS crhandler shim.

## Build Requirements

- Bun (for transplant pipeline)
- NDK (for bionic libopentui.so build)
- UPX (for compressed variant)
- make, bash, standard coreutils
