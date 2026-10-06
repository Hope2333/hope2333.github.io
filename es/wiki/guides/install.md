---
title: "Guía de instalación"
lang: es
---

# Guía de instalación

La forma de instalar cada proyecto depende de si ya forma parte del repositorio de software de hope2333.

## Configurar el repositorio de software

Antes de instalar, hay que configurar primero el repositorio de hope2333. Se recomienda el script de un solo paso (migra automáticamente las configuraciones antiguas):

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

O, con un solo comando, configurar e instalar directamente (`--install <paquete>`; la lista de paquetes disponibles está en `--help` del script):

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

También puedes configurar manualmente la fuente unificada más el paquete mirrorlist.

**Clientes pacman**: añade la sección unificada a `$PREFIX/etc/pacman.conf`:

```ini
[hope2333]
Server = https://github.com/Hope2333/codegraph-termux/releases/latest/download/
Server = https://github.com/Hope2333/opencode-termux/releases/latest/download/
Server = https://github.com/Hope2333/MiMoCode-Termux/releases/download/Push260829/
Server = https://github.com/Hope2333/freebuff-termux/releases/latest/download/
Server = https://github.com/Hope2333/codebuff-termux/releases/latest/download/
Server = https://hope2333.github.io/repo/Termux/pacman/
SigLevel = Optional TrustAll
```

A continuación, instala el paquete mirrorlist:

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

El hook posterior a la instalación del paquete sustituye la sección manual por una única línea `Include = /etc/pacman.d/hope2333-mirrorlist.conf` (el conf gestionado incluye la cabecera de sección `[hope2333]` y las directivas Server/SigLevel, que surten efecto vía Include; si se conserva una sección con el mismo nombre en pacman.conf, se registra dos veces y se pierden los Server). A partir de ese momento, cualquier cambio de fuente se aplica al actualizar el paquete.

**Clientes apt**: escribe la línea de arranque en `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`:

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

Después instala el paquete mirrorlist:

```sh
apt update && apt install hope2333-mirrorlist
```

El paquete escribe hope2333.list (5 líneas flat, apuntando al Release latest de cada repositorio).

> La línea antigua `deb .../repo/Termux/apt/ stable main` ya no es válida (io ya no aloja el repositorio apt); elimínala o sustitúyela por la línea de arranque. Si tienes una sección de arranque antigua `[hope2333-meta]` o un bloque pacman antiguo `[hope2333]`, sustitúyelo en bloque por la sección unificada, no lo añadas a mayores (el registro duplicado produce el error database already registered); o simplemente vuelve a ejecutar install.sh para que la migración se haga automáticamente.

## Proyectos ya incorporados al repositorio (pacman)

Para los proyectos ya incorporados, usa pacman como vía preferente. Tomando codegraph como ejemplo:

```sh
pacman -Sy codegraph
```

También puedes usar el script de un solo paso para hacerlo todo de una vez (configuración + instalación):

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install codegraph
```

`-Sy` actualiza primero el repositorio y luego instala, garantizando que obtienes la versión más reciente. Más repositorios se irán incorporando al fuente.

## Proyectos aún no incorporados (instalación manual desde GitHub)

Para los proyectos que todavía no están en el repositorio, acude al repositorio de GitHub correspondiente; las instrucciones de instalación están en el README de cada uno. Los enlaces a los repositorios están en el [índice de proyectos](../index.md).

## Verificar la instalación

Una vez finalizada la instalación, puedes verificarla con el parámetro `--version`: si muestra correctamente el número de versión, la instalación fue exitosa.
