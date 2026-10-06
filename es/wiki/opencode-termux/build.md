---
title: "Compilar opencode-termux"
lang: es
---

# Compilar opencode-termux

## Objetivos de make

```bash
make all VER=1.18.27 PKG=both        # Compilar todas las familias para una versión
make batch VERS='1.18.15 1.18.27' PKG=deb  # Compilar un rango
make selfcheck                        # Validar la configuración
```

### Objetivos por familia

```bash
make family-glibc VER=1.18.27        # Solo la línea glibc
make family-native VER=1.18.27       # Solo la línea nativa
make family-compressed VER=1.18.27   # Solo la comprimida (UPX)
```

### Scripts por lotes

- `scripts/range-build.sh` — modo DRY=1, salvavidas de disco, continuar ante fallos
- `scripts/fleet-upx.sh` — compresión UPX distribuida
- `scripts/sha-stage.sh` — acumulación de SHA256SUMS
- `scripts/push-stage.sh` — subida de release en modo dry-run
- `tools/maintain.sh` — operaciones de mantenedor: `--upload` (subida dirigida por make; la familia comprimida puede repartirse entre nodos de flota), `--auto-clean` (limpieza de la caché local tras la subida), `--clear`; primero la ayuda: `tools/maintain.sh --help`

## Pipeline de transplante (nativa)

La línea nativa usa una pipeline de transplante y reanimación (transplant-revive):

1. **Extract**: ELF base de Bun desde la compilación oficial de Android
2. **Detect**: formato de sección (automático según la versión de Bun)
3. **Convert**: inserción del grafo de módulos
4. **Patch**: BUN_COMPILED.size + offsets
5. **Assemble**: disposición final del ELF
6. **Revive**: cirugía de reanimación en runtime
7. **Verify**: ejecución de la autoprueba

Tras el transplante, un paso de endurecimiento seccomp añade el shim SIGSYS crhandler.

## Requisitos de compilación

- Bun (para la pipeline de transplante)
- NDK (para compilar la libopentui.so bionic)
- UPX (para la variante comprimida)
- make, bash y las coreutils estándar
