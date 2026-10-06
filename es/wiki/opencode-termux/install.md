---
title: "Instalar opencode-termux"
lang: es
---

# Instalar opencode-termux

## Vía el repositorio pacman de hope2333 (recomendado)

Una única fuente unificada llamada `[hope2333]`: se prueban primero los servidores CDN de GitHub release de cada repositorio y esta web de Pages actúa como respaldo. La fuente incluye los paquetes más recientes de cada repositorio de feed (instantánea de versión única).

### Arranque inicial (solo la primera vez)

Instala el paquete mirrorlist gestionado (URL fija, sin tag):

```bash
pacman -U https://github.com/Hope2333/hope2333.github.io/releases/latest/download/hope2333-mirrorlist-latest-1-any.pkg.tar.xz
```

Esto escribe `/etc/pacman.d/hope2333-mirrorlist.conf` y lo incluye desde `/etc/pacman.conf`.

### Instalar las familias

```bash
# Línea principal nativa v2 (recomendada — sin dependencias de glibc, Android API >= 28)
pacman -S opencode

# Línea principal nativa v1 (coexiste con la v2)
pacman -S opencode1

# Familias de apéndice / comprimida (fuera del lote raw de Push261005):
pacman -S opencode-wrapper        # apéndice wrapper v2
pacman -S opencode1-wrapper       # apéndice wrapper v1 (payload glibc)
pacman -S opencode1-compressed    # comprimida v1 (UPX, .pkg.tar.gz)
```

Los nombres antiguos `opencode-glibc` / `opencode-compressed` están retirados y la base de datos `[hope2333]` ya no los sirve: pasa a usar `opencode-wrapper` / `opencode1-compressed` respectivamente.

## Vía índice flat de apt

Los índices flat de cada repositorio viajan con los assets del release más reciente:

- opencode-termux: <https://github.com/Hope2333/opencode-termux/releases/download/Push260912/Packages.gz> — **fijado (pinned)**: desde Push261005 los releases ya no publican `Packages.gz` (`latest/download` → 404), así que el índice flat de apt está fijado al tag más reciente que todavía lo publicaba; el `hope2333.list` del deb mirrorlist lleva la misma URL fijada. Desfija cuando los releases vuelvan a publicar el índice.

## Instalación manual

### Nativa (opencode / opencode1)

```bash
pacman -U opencode-<ver>-<rel>-aarch64.pkg.tar.xz
dpkg -i opencode_<ver>_aarch64.deb
```

### Wrapper (opencode-wrapper / opencode1-wrapper)

```bash
pacman -U opencode-wrapper-<ver>-<pkgrel>-aarch64.pkg.tar.xz
dpkg -i opencode-wrapper_<ver>_aarch64.deb
```

### Comprimida (opencode1-compressed) — empaquetada con UPX, `.pkg.tar.gz`

```bash
pacman -U opencode1-compressed-<ver>-<pkgrel>-aarch64.pkg.tar.gz
dpkg -i opencode1-compressed_<ver>_aarch64.deb
```

### Standalone (opencode-glibc-standalone) — retirada, ya no se proporciona

> **Ya no se proporciona.** `opencode-glibc-standalone` está retirada y ya no se publica en el repositorio ni en los releases; sus instrucciones de instalación quedan retiradas. Usa en su lugar la línea principal `opencode` (nativa) o `opencode-wrapper`.

## Exclusión mutua

Dentro de una misma generación (v1 o v2), nativo / wrapper / comprimido son mutuamente excluyentes: elige UNO. Entre generaciones, la v1 (`opencode1*`) y la v2 (`opencode*`) coexisten; `*-standalone` es la excepción de coexistencia.

## Cambiar de proveedor

Instala el nuevo proveedor: dpkg/pacman sustituirá automáticamente el que entra en conflicto.

## Requisitos

- Android API >= 28
- Termux (todas las familias; las familias nativas no necesitan los paquetes `glibc` de Termux)
