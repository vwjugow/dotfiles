# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot). Config files live under `to_sync_files/` and are symlinked into `$HOME` by dotbot; the rest of the repo bootstraps a fresh machine (package install, shell setup) per operating system.

## Install / apply changes

```bash
./install            # full bootstrap: update submodules, run dotbot, then OS-specific setup
```

To only re-apply symlinks without the OS setup, run dotbot directly:
```bash
./dotbot/bin/dotbot -c to_sync_files/install.conf.yaml
```

## Architecture

- **`to_sync_files/`** - the source of truth for every dotfile. Editing a config means editing the file here, not the symlink target in `$HOME`.
- **`scripts/`** (repo root, distinct from `to_sync_files/scripts/`) - machine bootstrap only, one subdirectory per OS.

## Shell environment

When adding a shell alias or function, put it in `to_sync_files/scripts/aliases.sh` under the matching section.

## Conventions

- ASCII only in all files (no em dashes, curly quotes, or other non-ASCII).
- Do not delete files; use `git rm` / `git mv` if a file needs to move, otherwise flag it for manual removal.
