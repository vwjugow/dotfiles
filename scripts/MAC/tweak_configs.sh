#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/detect_arch.sh"

# On a fresh machine the current shell does not have MacPorts on PATH yet, and
# asdf below comes from MacPorts on Intel.
if ! is_apple_silicon && [ -x "$PORT_BIN" ]; then
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

# Homebrew prefix is /opt/homebrew on Apple Silicon and /usr/local on Intel.
BREW_POSTGRES_DIR="$(brew --prefix 2>/dev/null)/opt/postgresql"
if [ -d "$BREW_POSTGRES_DIR" ]; then
    ln -sfv "$BREW_POSTGRES_DIR"/*.plist ~/Library/LaunchAgents
fi

# Command line tools from asdf: these plugins download the project's prebuilt
# release binary, so nothing is compiled on either architecture.
# Plugin URLs are given explicitly so a broken ~/.asdf/plugin-index does not matter.
ASDF_PLUGINS=(
    "github-cli https://github.com/bartlomiejdanek/asdf-github-cli.git"
    "nodejs https://github.com/asdf-vm/asdf-nodejs.git"
)
for entry in "${ASDF_PLUGINS[@]}"; do
    read -r name url <<< "$entry"
    asdf plugin list 2>/dev/null | grep -qx "$name" || asdf plugin add "$name" "$url"
    asdf install "$name" latest
    asdf set -u "$name" latest
done
