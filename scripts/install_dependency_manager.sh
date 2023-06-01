#!/bin/bash

DISTRO=$1
if [[ $DISTRO == "MANJARO" ]]; then
    if [[ -z $(which yay) ]]; then
        echo "Installing yay"
        git clone https://aur.archlinux.org/yay-git.git
        cd yay-git
        makepkg --noconfirm -si
        cd -
        rm -rf yay-git
    fi
    yay
fi
