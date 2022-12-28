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
    autoconf
    bluez
    bluez-utils
    blueman
    brave-bin
    gvim
    libreoffice-fresh
    masterpdfeditor-free
    meld
    networkmanager
    networkmanager-openvpn
    network-manager-applet
    nodejs-gitmoji-cli
    nvidia
    neovim
    openssh
    ranger
    simplescreenrecorder
    skypeforlinux-stable-bin
    screen
    slack-desktop
    spotify
    terminator
    telegram-desktop
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

LOG_FILE="log.out"
echo > $LOG_FILE
for pkg in ${TO_RM_PACKAGES[@]}; do
    yayUninstall $pkg $LOG_FILE
done
for pkg in ${PACKAGES[@]}; do
    yayInstall $pkg $LOG_FILE
done
