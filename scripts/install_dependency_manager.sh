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
if [[ $DISTRO == "MAC" ]]; then
    DEP_MGR="brew"
    if [[ -z $(which ${DEP_MGR}) ]]; then
        echo "Installing ${DEP_MGR}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    ${DEP_MGR} update
fi
