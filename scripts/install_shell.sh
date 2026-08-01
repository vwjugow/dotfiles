#!/usr/bin/env bash

echo ">>> Installing oh-my-zsh"
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    # dotbot may have already created $HOME/.oh-my-zsh as scaffolding for the
    # custom/themes/powerlevel10k symlink; the installer refuses to run if
    # this directory already exists, so clear it first.
    rm -rf "$HOME/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

echo ">>> Changing default shell to zsh"
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi
