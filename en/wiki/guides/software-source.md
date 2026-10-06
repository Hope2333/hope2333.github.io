---
title: "Software Source"
lang: en
---

# Software Repository Guide

The entry point of the Hope2333 software repository is <https://hope2333.github.io/repo/>. It currently provides Termux (aarch64) packages and supports both pacman and apt clients.

## One-Click Setup (recommended)

Run the following command in Termux to configure the repository automatically:

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

What the script does:

- Detects the Termux environment automatically (reads `$PREFIX`, falling back to the default path when unset)
- Writes the unified `[hope2333]` section and installs the hope2333-mirrorlist package (already included in the unified repository); for apt clients it writes the hope2333-bootstrap.list bootstrap line
- Migrates the old `[hope2333-meta]` bootstrap section / old `[hope2333]` block / old apt source configuration automatically
- Idempotent: skips configuration that already exists, never writes duplicates

The script accepts arguments: `--install <package>` (installs the given package right after configuration) and `--help` (usage and list of available packages). For example, configure and install in one line:

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

## Unified Section + mirrorlist Package (manual)

If you would rather not run the script, configure the unified section manually per client, then install the mirrorlist package.

**pacman users**: append the unified section to `$PREFIX/etc/pacman.conf`:

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

After the package is installed, its hook replaces the manual section with a single `Include = /etc/pacman.d/hope2333-mirrorlist.conf` line (the managed conf carries its own `[hope2333]` section header and Server/SigLevel, effective via the include; keeping a same-named section in pacman.conf as well would register it twice and drop Servers). From then on, repository changes take effect through package upgrades.

**apt users**: write the bootstrap line to `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`:

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

```sh
apt update && apt install hope2333-mirrorlist
```

The package ships hope2333.list (5 flat lines pointing at each repository's Release latest).

> The old `deb .../repo/Termux/apt/ stable main` line is no longer valid (the io site no longer hosts the apt repository) — remove it or replace it with the bootstrap line. If you still have an old `[hope2333-meta]` bootstrap section or an old `[hope2333]` pacman block, replace it wholesale with the unified section instead of appending (duplicate registration fails with "database already registered"); or simply re-run install.sh to migrate automatically.

## Manual Configuration (without the mirrorlist package)

See [/repo/Termux/](https://hope2333.github.io/repo/Termux/) for full instructions. For pacman, the recommended layout mirrors what the mirrorlist package ships (a single section with multiple Servers, repository releases first, the site as fallback):

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

The mirrorlist package is simply a persisted copy of this section (`/etc/pacman.d/hope2333-mirrorlist.conf`), updated with the package; writing it manually is equivalent to pinning a snapshot.

For apt, which uses flat repositories, write the following 5 lines to `$PREFIX/etc/apt/sources.list.d/hope2333.list`:

```text
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codegraph-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/opencode-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/MiMoCode-Termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/freebuff-termux/releases/latest/download/ ./
deb [trusted=yes arch=aarch64] https://github.com/Hope2333/codebuff-termux/releases/latest/download/ ./
```

Packages indexes are already provided in each repository's release, so the flat lines work as-is.

## Common Usage

Once configured, common pacman commands:

```sh
pacman -Sy              # refresh repository indexes
pacman -Sy <package>    # install a package (refreshing indexes at the same time)
pacman -Syu             # refresh indexes and upgrade all packages
pacman -Ss <keyword>    # search for packages
pacman -R <package>     # remove a package
```

Common apt commands:

```sh
apt update              # refresh repository indexes
apt install <package>   # install a package
apt upgrade             # upgrade all packages
apt search <keyword>    # search for packages
```

For day-to-day upgrades, see the [update guide](update.md).

## Roadmap

Signature verification (repo-add -s / Release signatures) will be introduced later; the current v1 repository is unsigned.
