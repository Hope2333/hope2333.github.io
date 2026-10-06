---
title: "Arquitectura"
lang: es
---

# Arquitectura

## Pipeline de transplante

La innovación central: injertar el grafo de módulos JavaScript de OpenCode en el ELF de Bun oficial de Android y, a continuación, ejecutar una «cirugía de reanimación» para producir un único ejecutable Bionic.

```
ELF oficial de Bun → Extracción → Inserción del grafo de módulos → Parcheo → Ensamblado → Reanimación → Binario funcional
```

Idea clave: el fallo original («cero glibc es imposible») se debía a que `assemble` nunca parcheaba `BUN_COMPILED.size` en la sección `.bun`. Corregido en la pipeline de transplante.

## Shim seccomp SIGSYS

Protección de doble capa:

- **Handler**: intercepción inline de syscalls + interpositor de DT_NEEDED[0]
- **Interpositor PLT**: captura las syscalls de los procesos hijos

Esto garantiza que el binario gestione con elegancia las restricciones seccomp de Android.

## TUI (libopentui.so)

Una `libopentui.so` bionic construida por nosotros (compilada con el NDK) proporciona el renderizado de la interfaz de terminal. Se sustituye dentro del binario a longitud igual mediante `tools/transplant/swap_tui.py`.

- Prueba de humo profunda W10a: 5/5 superadas (chat real, resize, salida limpia, soak de 5 min)
- El RSS de hecho disminuye en reposo (estabilidad demostrada)

## Watcher nativo

`tools/watcher/` ofrece un demonio independiente de vigilancia de archivos:
- `watcher.c` — vigilancia recursiva inotify con NDK
- `shim.js` — interfaz del lado del plugin
- E2E: los tres tipos de evento en <100 ms, auto-reparación ≤612 ms

## Formato de paquete

- `bin/opencode` es un ELF ejecutable real (sin wrapper de bash)
- Exclusión mutua a tres bandas: opencode ↔ opencode-glibc ↔ opencode-compressed
- Variante standalone: entrada `bin/opencode-glibc`, coexiste con la nativa
- Los paquetes glibc son solo binarios y autosuficientes (no necesitan los paquetes glibc de Termux)
- Los paquetes comprimidos incluyen siempre `usr/lib/opencode/libopencode-crhandler.so` (DT_RUNPATH $ORIGIN/../lib/opencode)
