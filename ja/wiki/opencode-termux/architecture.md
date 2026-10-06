---
title: "アーキテクチャ"
lang: ja
---

# アーキテクチャ

## Transplant パイプライン

中核となるアイデア：OpenCode の JavaScript モジュールグラフを公式 Android Bun ELF に移植し、「revive 手術」を実行して、単一の Bionic 実行ファイルを生成します。

```
公式 Bun ELF → Extract → モジュールグラフ挿入 → Patch → Assemble → Revive → 動作するバイナリ
```

重要な着眼点：当初の失敗（「ゼロ glibc は不可能」）は、`assemble` が `.bun` セクション内の `BUN_COMPILED.size` をパッチしていなかったことが原因でした。transplant パイプラインで修正済みです。

## Seccomp SIGSYS Shim

二層の保護：

- **Handler**: インライン syscall インターセプト + DT_NEEDED[0] インターポーザ
- **PLT インターポーザ**: 子プロセスからの syscall を捕捉

これにより、バイナリは Android の seccomp 制限を適切に処理できます。

## TUI（libopentui.so）

NDK でコンパイルした自前の bionic `libopentui.so` がターミナル UI の描画を担います。`tools/transplant/swap_tui.py` により等長置換でバイナリに組み込まれます。

- W10a ディープスモークテスト：5/5 合格（実際のチャット、リサイズ、クリーン終了、5 分間 soak）
- アイドル中に RSS が実際に減少する（安定性を実証）

## Native Watcher

`tools/watcher/` はスタンドアロンのファイル監視デーモンを提供します：
- `watcher.c` — NDK inotify による再帰監視
- `shim.js` — プラグイン側インターフェース
- E2E：3 種類のイベントすべて 100ms 未満、自己修復 ≤612ms

## パッケージ形式

- `bin/opencode` は実体のある実行可能 ELF（bash ラッパーなし）
- 三者間の相互排他：opencode ↔ opencode-glibc ↔ opencode-compressed
- Standalone バリアント：`bin/opencode-glibc` エントリ、native と共存
- glibc パッケージは bin-only で自己完結（Termux の glibc パッケージ不要）
- 圧縮パッケージは常に `usr/lib/opencode/libopencode-crhandler.so` を同梱（DT_RUNPATH $ORIGIN/../lib/opencode）
