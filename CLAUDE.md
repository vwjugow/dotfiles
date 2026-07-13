# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot). Config files live under `to_sync_files/` and are symlinked into `$HOME` by dotbot; the rest of the repo bootstraps a fresh machine (package install, shell setup) per operating system.

## Install / apply changes

```bash
./install            # full bootstrap: update submodules, run dotbot, then OS-specific setup
```

`./install` does, in order:
1. `git pull --recurse-submodules && git submodule update`
2. Runs dotbot with `to_sync_files/install.conf.yaml` to create/relink symlinks
3. Detects the OS from `uname -a` (MANJARO / UBUNTU / MAC) and runs `scripts/install_dependency_manager.sh`, `scripts/<DISTRO>/install_packages.sh`, `scripts/<DISTRO>/tweak_configs.sh`, then `scripts/install_shell.sh`

To only re-apply symlinks without the OS setup, run dotbot directly:
```bash
./dotbot/bin/dotbot -c to_sync_files/install.conf.yaml
```

Note: only `scripts/MANJARO/` exists. `UBUNTU` and `MAC` are detected but have no `install_packages.sh` / `tweak_configs.sh`, so `./install` will fail partway on those. On macOS, use dotbot directly for symlinking.

## Architecture

- **`to_sync_files/`** - the source of truth for every dotfile. Editing a config means editing the file here, not the symlink target in `$HOME`. `install.conf.yaml` maps each source file to its `$HOME` destination (e.g. `zshrc` -> `~/.zshrc`, `scripts` -> `~/.scripts`). Some links use `force: true` to overwrite existing files.
- **`to_sync_files/scripts/`** - symlinked to `~/.scripts`. `aliases.sh` is the large, central alias/function file sourced by `zshrc`; it holds all shell shortcuts grouped by domain (GIT, DOCKER, AWS, BriteCore, MAVEN, SQL, Kubectl, etc.). Also contains helpers like `create_pr.sh`, `gitpull`.
- **Submodules** (see `.gitmodules`) - `dotbot` (the installer), `fzf`, `powerlevel10k`, `xkblayout-state`. `.gitmodules` sets `ignore = dirty` so submodule working-tree changes don't show in status. `install.conf.yaml` symlinks submodule dirs into place (e.g. `../fzf` -> `~/.fzf`, `../powerlevel10k` -> oh-my-zsh custom themes).
- **`scripts/`** (repo root, distinct from `to_sync_files/scripts/`) - machine bootstrap only: `install_dependency_manager.sh` (installs `yay` on Manjaro), `install_shell.sh` (oh-my-zsh + default shell to zsh), and `scripts/MANJARO/` for package install and system tweaks (asdf, systemd services).

## Shell environment

`zshrc` uses oh-my-zsh with the `powerlevel10k` theme and plugins `(git docker-compose asdf)`. It sources `~/.p10k.zsh`, `~/.fzf.zsh`, then `~/.scripts/aliases.sh`. Language runtimes are managed by `asdf`. When adding a shell alias or function, put it in `to_sync_files/scripts/aliases.sh` under the matching section.

## Conventions

- ASCII only in all files (no em dashes, curly quotes, or other non-ASCII).
- Do not delete files; use `git rm` / `git mv` if a file needs to move, otherwise flag it for manual removal.
