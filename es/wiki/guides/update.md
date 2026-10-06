---
title: "Guía de actualización"
lang: es
---

# Guía de actualización

## Actualizaciones del día a día

Cliente pacman:

```sh
pacman -Syu
```

Cliente apt:

```sh
apt update && apt upgrade
```

`apt upgrade` actualiza también hope2333-mirrorlist (la lista de fuentes se actualiza con el paquete); el cliente pacman funciona igual. Conviene ejecutarlo con regularidad para mantener los paquetes en la versión más reciente.

## Mecanismo de publicación de versiones

Cada repositorio publica mediante tags Push (por ejemplo, Push260906), y `releases/latest/download` apunta siempre al lote formal más reciente; la fuente unificada y los paquetes de la web se sincronizan automáticamente tras cada publicación mediante el flujo site-rebuild. Por eso no hace falta preocuparse por los nombres de los tags: lo que traiga `pacman -Syu` / `apt upgrade` es la compilación más reciente disponible.

## Sincronización del repositorio

El contenido del repositorio de software se sincroniza mediante el flujo site-rebuild: cuando un repositorio se actualiza, el cambio se refleja automáticamente en la fuente.
