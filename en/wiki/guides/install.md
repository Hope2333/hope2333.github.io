---
title: "Install"
lang: en
---

# Installation Guide

How you install each project depends on whether it has made it into the hope2333 repository.

## Configure the Software Repository

Before installing, you need to configure the hope2333 repository. The recommended way is the one-click script (it automatically migrates old configurations):

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh
```

Or configure and install in one line (`--install <package>`; run the script with `--help` for the list of available packages):

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install opencode
```

Alternatively, configure the unified section plus the mirrorlist package manually.

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

Then install the mirrorlist package:

```sh
pacman -Sy && pacman -S hope2333-mirrorlist
```

After the package is installed, its hook replaces the manual section with a single `Include = /etc/pacman.d/hope2333-mirrorlist.conf` line (the managed conf carries its own `[hope2333]` section header and Server/SigLevel, effective via the include; keeping a same-named section in pacman.conf as well would register it twice and drop Servers). From then on, repository changes take effect through package upgrades.

**apt users**: write the bootstrap line to `$PREFIX/etc/apt/sources.list.d/hope2333-bootstrap.list`:

```text
deb [trusted=yes arch=aarch64] https://hope2333.github.io/repo/Termux/apt/ ./
```

Then install the mirrorlist package:

```sh
apt update && apt install hope2333-mirrorlist
```

The package ships hope2333.list (5 flat lines pointing at each repository's Release latest).

> The old `deb .../repo/Termux/apt/ stable main` line is no longer valid (the io site no longer hosts the apt repository) — remove it or replace it with the bootstrap line. If you still have an old `[hope2333-meta]` bootstrap section or an old `[hope2333]` pacman block, replace it wholesale with the unified section instead of appending (duplicate registration fails with "database already registered"); or simply re-run install.sh to migrate automatically.

## Projects in the Repository (pacman)

For projects already in the repository, prefer pacman. Taking codegraph as an example:

```sh
pacman -Sy codegraph
```

You can also use the one-click script to configure and install in a single step:

```sh
curl -fsSL https://hope2333.github.io/repo/install.sh | sh -s -- --install codegraph
```

`-Sy` refreshes the repository index before installing, so you always get the latest version. More repositories will be added to the source over time.

## Projects Not Yet in the Repository (manual install from GitHub)

For projects not yet in the repository, get them from the project's GitHub repository; see the repository README for installation instructions. Repository links for each project are listed in the [project index](../index.md).

## Verify the Installation

Once installed, verify with the `--version` flag — a normal version output means the installation succeeded.
