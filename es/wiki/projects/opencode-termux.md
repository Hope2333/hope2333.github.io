---
title: "opencode-termux"
lang: es
---

# opencode-termux

> OpenCode en Termux/Android, el proyecto insignia

## Introducción

OpenCode on Termux/Android es el proyecto insignia de Hope2333. Consigue que OpenCode funcione en entornos Termux/Android y es el más destacado de todos los proyectos recogidos en este sitio.

## Instalación

Este proyecto ya está en el repositorio de software de hope2333 (pacman, fuente unificada `[hope2333]`: se priorizan las librerías release de cada repositorio, con esta web como respaldo). Se recomienda instalarlo directamente:

```bash
# Línea principal nativa (recomendada)
pacman -S opencode

# Apéndice glibc (compuesto autosuficiente, solo binarios)
pacman -S opencode-glibc

# Variante comprimida (UPX, con shim crhandler incluido)
pacman -S opencode-compressed
```

Consulta la [guía de instalación del wiki](/wiki/opencode-termux/install.md) para más detalles.

## Enlaces

- **Wiki**: [/wiki/opencode-termux/](/wiki/opencode-termux/)
- Repositorio de GitHub: <https://github.com/Hope2333/opencode-termux>
- Lista de versiones (sin pin de tag): <https://github.com/Hope2333/opencode-termux/releases>
