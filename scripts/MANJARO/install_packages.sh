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
    glibc
    gvim
    jump
    lazydocker
    lazygit
    libx11
    masterpdfeditor-free
    ngrok
    nodejs-gitmoji-cli
    noto-fonts-emoji
    nvidia
    openssh
    pacman-contrib
    postgresql
    powershift
    ranger
    redshift
    simplescreenrecorder
    screen
    systemd-numlockontty
    tailscale
    terminator
    telegram-desktop
    texlive-latexextra
    the_silver_searcher
    tk
    unrar
    unzip
    windsurf
    xf86-input-synaptics
    xkblayout-state
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

function install_llama {
    curl -fsSL https://ollama.com/install.sh | sh
}

LOG_FILE="log.out"
echo > $LOG_FILE
for pkg in ${TO_RM_PACKAGES[@]}; do
    yayUninstall $pkg $LOG_FILE
done
for pkg in ${PACKAGES[@]}; do
    yayInstall $pkg $LOG_FILE
done
if [ -z $(which pulseaudio) ]; then
    install_pulse
fi
install_llama
# install_1pw
# install_aws
