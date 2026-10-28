---
title: "opencode-termux"
lang: es
---

# opencode-termux

OpenCode on Termux/Android — proyecto insignia.

## Resumen

opencode-termux lleva [OpenCode](https://github.com/anomalyco/opencode) a Termux/Android mediante un runtime Bionic nativo. El proyecto produce un único ELF de Android sin glibc a través de una pipeline de transplante y reanimación (transplant-revive), distribuido en versiones formales bajo el nombre de paquete `opencode`.

## Familias de paquetes

Cinco familias repartidas en dos generaciones, instalables en paralelo (v1 y v2 coexisten):

| Paquete | Gen | Estado | Runtime |
|---------|-----|--------|---------|
| **Nativo (línea principal)** | v2 | `opencode` | Estable — Bionic puro, sin dependencias de glibc |
| **Wrapper (apéndice)** | v2 | `opencode-wrapper` | Wrapper de bun-termux-loader |
| **Nativo (línea principal v1)** | v1 | `opencode1` | Estable — Bionic puro, sin dependencias de glibc |
| **Wrapper (apéndice v1)** | v1 | `opencode1-wrapper` | Payload runtime glibc |
| **Comprimido (v1)** | v1 | `opencode1-compressed` | Nativo empaquetado con UPX (`.pkg.tar.gz`) |

Dentro de una misma generación elige exactamente UNO entre nativo / wrapper / comprimido; la v1 (`opencode1*`) y la v2 (`opencode*`) coexisten. Los nombres antiguos `opencode-glibc`, `opencode-compressed` y `opencode-glibc-standalone` están retirados y se eliminaron en firme de la base de datos unificada `[hope2333]`.

> **最新批次（Push261026）**：v2 **2.1.4** + **2.0.32** native 发布（deb + pacman）— 2.1.4 修复 OpenTUI 0.6.8 ABI 错配（首版 TUI 报 `ot_scene_set_hooks not found`），构建改为按 `OPENTUI_VER` 选渲染库、未知版本硬失败；两版本在 Android 9 / kernel 3.18.140 实测 TUI 完整可用。本批仅 native；v1 仍为 1.19.3（1.19.4 待源码重建）。详见 [Push261026 发布页](release/Push261026.md)。

## Instalación rápida

```bash
# Vía el repositorio pacman de hope2333 (recomendado)
pacman -S opencode     # línea principal nativa v2
pacman -S opencode1    # línea principal nativa v1 (coexiste con la v2)
```

Consulta la [guía de instalación](install.md) para más detalles.

## Enlaces

- [GitHub](https://github.com/Hope2333/opencode-termux)
- [Guía de instalación](install.md)
- [Compilar desde el código fuente](build.md)
- [Arquitectura](architecture.md)
- [Versiones (sin pin de tag)](https://github.com/Hope2333/opencode-termux/releases)
