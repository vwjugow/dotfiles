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
    source "$(dirname "${BASH_SOURCE[0]}")/MAC/detect_arch.sh"

    # Homebrew on both architectures: all packages on Apple Silicon, casks
    # only on Intel. Its installer also installs the Xcode Command Line Tools,
    # which MacPorts needs.
    if [[ -z $(which brew) ]]; then
        echo "Installing brew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update

    # MacPorts on Intel for command line packages. Its release assets are
    # named MacPorts-<version>-<macOS major>-<macOS name>.pkg.
    if ! is_apple_silicon; then
        if [[ ! -x $PORT_BIN ]]; then
            macos_major="$(sw_vers -productVersion | cut -d. -f1)"
            pkg_url="$(curl -fsSL https://api.github.com/repos/macports/macports-base/releases/latest \
                | grep -o "\"browser_download_url\": *\"[^\"]*-${macos_major}-[A-Za-z]*\.pkg\"" \
                | sed -E 's/.*"(https[^"]+)"/\1/' | head -1)"
            if [[ -z $pkg_url ]]; then
                echo "No MacPorts installer found for macOS ${macos_major}" && exit 1
            fi
            echo "Installing MacPorts from ${pkg_url}"
            tmp_dir="$(mktemp -d)"
            curl -fsSL "$pkg_url" -o "${tmp_dir}/MacPorts.pkg"
            sudo installer -pkg "${tmp_dir}/MacPorts.pkg" -target /
            rm -rf "$tmp_dir"
        fi
        sudo "$PORT_BIN" selfupdate
    fi
fi
