---
title: "opencode-termux のビルド"
lang: ja
---

# opencode-termux のビルド

## Make ターゲット

```bash
make all VER=1.18.27 PKG=both        # 指定バージョンの全ファミリーをビルド
make batch VERS='1.18.15 1.18.27' PKG=deb  # 範囲ビルド
make selfcheck                        # セットアップの検証
```

### ファミリー別ターゲット

```bash
make family-glibc VER=1.18.27        # glibc ラインのみ
make family-native VER=1.18.27       # native ラインのみ
make family-compressed VER=1.18.27   # 圧縮版（UPX）のみ
```

### バッチスクリプト

- `scripts/range-build.sh` — DRY=1 モード、ディスクガードレール、失敗時も継続
- `scripts/fleet-upx.sh` — 分散 UPX 圧縮
- `scripts/sha-stage.sh` — SHA256SUMS の蓄積
- `scripts/push-stage.sh` — リリースアップロードのドライラン
- `tools/maintain.sh` — メンテナー操作：`--upload`（make 駆動のアップロード。compressed ファミリーはフリートノードへ fan out 可能）、`--auto-clean`（アップロード後のローカルキャッシュ削除）、`--clear`。まずはヘルプ：`tools/maintain.sh --help`

## Transplant パイプライン（Native）

native ラインは transplant-revive パイプラインを使います：

1. **Extract**: 公式 Android ビルドからベース Bun ELF を取り出す
2. **Detect**: セクション形式の検出（Bun バージョンごとに自動）
3. **Convert**: モジュールグラフの挿入
4. **Patch**: BUN_COMPILED.size とオフセットの修正
5. **Assemble**: 最終 ELF レイアウトの組み立て
6. **Revive**: 実行時復活手術
7. **Verify**: セルフテストの実行

transplant の後、seccomp-harden ステップが SIGSYS crhandler shim を追加します。

## ビルド要件

- Bun（transplant パイプライン用）
- NDK（bionic libopentui.so のビルド用）
- UPX（圧縮バリアント用）
- make、bash、標準 coreutils
