TO_RM_PACKAGES=(
    libreoffice-still
    vim
)

PACKAGES=(
    accountsservice
    acpi_call
    alacarte
    alsa-firmware
    alsa-ucm-conf
    alsa-utils
    alttab-git
    arandr
    asdf-vm
    aur/dropbox
    autoconf
    bluez
    bluez-utils
    blueman
    brave-bin
    community/playerctl
    community/ack
    docker
    docker-compose
    extra/texlive-core
    glibc
    gvim
    jump
    libreoffice-fresh
    libx11
    masterpdfeditor-free
    meld
    networkmanager
    networkmanager-openvpn
    network-manager-applet
    nodejs-gitmoji-cli
    nvidia
    neovim
    openssh
    postgresql
    ranger
    simplescreenrecorder
    skypeforlinux-stable-bin
    screen
    slack-desktop
    spotify
    terminator
    telegram-desktop
    terraform
    texlive-latexextra
    the_silver_searcher
    tk
    unrar
    unzip
    whatsapp-nativefier
    xf86-input-synaptics
    youtube-dl
    zip
    zoom
    zsh
)

function yayInstall {
  LOG_FILE=$2
  pacman -Qi $1 &> /dev/null
  if [ $? -ne 0 ]; then
    echo -e ">>> Installing ${1}" >> $LOG_FILE
    yes | yay --noconfirm -S $1 >> $LOG_FILE 2>&1
  else
    echo -e ">>> Already installed: ${1}" >> $LOG_FILE
  fi
}

function yayUninstall {
  LOG_FILE=$2
  pacman -Qi $1 &> /dev/null
  if [ $? -ne 1 ]; then
    echo -e ">>> Uninstalling ${1}" >> $LOG_FILE
    yes | yay --noconfirm -R $1 >> $LOG_FILE 2>&1
  else
    echo -e ">>> Not installed: ${1}" >> $LOG_FILE
  fi
}

function install_aws {
    if [[ -z `which aws` ]]; then
        echo "Installing aws cli"
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm awscliv2.zip
    fi
}

function install_1pw {
    echo "Installing 1Password"
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
    git clone --depth=1 https://aur.archlinux.org/1password.git
    cd 1password
    makepkg -si
}

LOG_FILE="log.out"
echo > $LOG_FILE
for pkg in ${TO_RM_PACKAGES[@]}; do
    yayUninstall $pkg $LOG_FILE
done
for pkg in ${PACKAGES[@]}; do
    yayInstall $pkg $LOG_FILE
done
install_1pw
install_aws
