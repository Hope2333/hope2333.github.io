---
title: "Update"
lang: en
---

# Update Guide

## Day-to-Day Updates

pacman users:

```sh
pacman -Syu
```

apt users:

```sh
apt update && apt upgrade
```

`apt upgrade` also upgrades hope2333-mirrorlist (the server list travels with the package); the same applies to pacman. Run these regularly to keep your packages up to date.

## Release Mechanism

Each repository publishes releases as Push tags (e.g. Push260906), and `releases/latest/download` always points to the newest official batch; the unified source and the site packages are synced automatically by the site-rebuild pipeline after each release. You therefore never need to care about tag names — whatever `pacman -Syu` / `apt upgrade` pulls down is the current latest build.

## Repository Synchronization

The repository content is synchronized by the site-rebuild pipeline; once a repository is updated, the changes are reflected in the software source automatically.
