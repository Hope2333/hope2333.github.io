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

> **Último lote (Push261104)**: correcciones de terminal + wrapper completo — v2 native **2.2.5-2** (PTY) y v1 native **1.19.4-2** (entrada de TUI), wrapper hasta v2 **2.0.0–2.2.5** (43 versiones) y v1 **1.18.30–1.19.5** (12 versiones), **116 assets**. Ver la [página de Push261104](release/Push261104.md).

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
