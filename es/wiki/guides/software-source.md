---
title: "Guía del repositorio de software"
lang: es
---

# Guía del repositorio de software

La puerta de entrada al repositorio de software de Hope2333 es <https://hope2333.github.io/repo/>. Actualmente ofrece paquetes para Termux (aarch64) y admite dos clientes: pacman y apt.

## Configuración en un solo paso (recomendada)

Ejecuta el siguiente comando en Termux para configurar el repositorio automáticamente:

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

Comportamiento del script:

- Detecta automáticamente el entorno Termux (lee `$PREFIX`, con respaldo a la ruta por defecto si no está definida)
- Escribe la fuente unificada `[hope2333]` e instala el paquete hope2333-mirrorlist (la biblioteca unificada ya incluye ese paquete); en clientes apt escribe la línea de arranque hope2333-bootstrap.list
- Migra automáticamente la sección de arranque antigua `[hope2333-meta]`, el bloque antiguo `[hope2333]` y las configuraciones apt antiguas
- Es idempotente: si ya está configurado, no escribe nada duplicado

El script admite parámetros: `--install <paquete>` (instala el paquete indicado justo tras la configuración) y `--help` (ayuda y lista de paquetes disponibles). Por ejemplo, configurar e instalar en una sola línea:

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

## Fuente unificada + paquete mirrorlist (manual)

Si prefieres no ejecutar el script, configura manualmente la fuente unificada según tu cliente y luego instala el paquete mirrorlist.

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

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

El hook posterior a la instalación del paquete sustituye la sección manual por una única línea `Include = /etc/pacman.d/hope2333-mirrorlist.conf` (el conf gestionado incluye la cabecera de sección `[hope2333]` y las directivas Server/SigLevel, que surten efecto vía Include; si se conserva una sección con el mismo nombre en pacman.conf, se registra dos veces y se pierden los Server). A partir de ese momento, cualquier cambio de fuente se aplica al actualizar el paquete.

**Clientes apt**: escribe la línea de arranque en `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`:

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

```sh
apt update && apt install hope2333-mirrorlist
```

El paquete escribe hope2333.list (5 líneas flat, apuntando al Release latest de cada repositorio).

> La línea antigua `deb .../repo/Termux/apt/ stable main` ya no es válida (io ya no aloja el repositorio apt); elimínala o sustitúyela por la línea de arranque. Si tienes una sección de arranque antigua `[hope2333-meta]` o un bloque pacman antiguo `[hope2333]`, sustitúyelo en bloque por la sección unificada, no lo añadas a mayores (el registro duplicado produce el error database already registered); o simplemente vuelve a ejecutar install.sh para que la migración se haga automáticamente.

## Configuración manual (sin instalar el paquete mirrorlist)

Consulta [/repo/Termux/](https://hope2333.github.io/repo/Termux/) para ver las instrucciones completas. En clientes pacman se recomienda seguir el formato unificado del paquete mirrorlist (una sola sección con varios Server, primero las bibliotecas de cada repositorio y la web como respaldo):

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

El paquete mirrorlist es precisamente la persistencia de esta sección (`/etc/pacman.d/hope2333-mirrorlist.conf`) y se actualiza con el paquete; escribirla a mano equivale a fijar una instantánea estática.

**Clientes apt**: usa fuentes flat; escribe estas 5 líneas en `$PREFIX/etc/apt/sources.list.d/hope2333.list`:

```text
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codegraph-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/opencode-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/MiMoCode-Termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/freebuff-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codebuff-termux/releases/latest/download/ ./
```

Los ficheros Packages ya están disponibles en los release de cada repositorio, por lo que las líneas flat pueden usarse directamente.

## Uso habitual

Una vez configurado, los comandos más usados en clientes pacman:

```sh
pacman -Sy              # Actualizar el repositorio
pacman -Sy <paquete>    # Instalar un paquete (actualizando el repositorio a la vez)
pacman -Syu             # Actualizar el repositorio y todos los paquetes
pacman -Ss <palabra>    # Buscar paquetes
pacman -R <paquete>     # Desinstalar un paquete
```

Y en clientes apt:

```sh
apt update              # Actualizar el repositorio
apt install <paquete>   # Instalar un paquete
apt upgrade             # Actualizar todos los paquetes
apt search <palabra>    # Buscar paquetes
```

Para las actualizaciones del día a día, consulta la [guía de actualización](update.md).

## Roadmap

En el futuro se incorporará la verificación de firmas (repo-add -s / firmas Release); la v1 actual no tiene firmas.
