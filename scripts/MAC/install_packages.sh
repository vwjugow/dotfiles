TO_RM_PACKAGES=(
)

PACKAGES=(
    coreutils
    findutils
    moreutils
    rename
    tree
    wget
    curl
    tag
    gpg
    gawk
    git
    jump
    lazydocker
    lazygit
    monit
    the_silver_searcher
    asdf
    alt-tab
    keka  # 7zip
    awscli
    zeromq
)

CASKS=(
    alfred
    spotify
    telegram
    visual-studio-code
    warp
    whatsapp
    zoomus
)

function brewInstall {
  LOG_FILE=$2
  brew list $1 &> /dev/null
  if [ $? -ne 0 ]; then
    echo -e ">>> Installing ${1}" >> $LOG_FILE
    brew install $1 >> $LOG_FILE 2>&1
  else
    echo -e ">>> Already enstalled: ${1}" >> $LOG_FILE
  fi
}

function brewCaskInstall {
  LOG_FILE=$2
  brew list $1 &> /dev/null
  if [ $? -ne 0 ]; then
    echo -e ">>> Installing ${1}" >> $LOG_FILE
    brew install --cask $1 >> $LOG_FILE 2>&1
  else
    echo -e ">>> Already enstalled: ${1}" >> $LOG_FILE
  fi
}

function brewUninstall {
  LOG_FILE=$2
  brew list $1 &> /dev/null
  if [ $? -ne 1 ]; then
    echo -e ">>> Uninstalling ${1}" >> $LOG_FILE
    brew uninstall --cask $1 >> $LOG_FILE 2>&1
  else
    echo -e ">>> Not installed: ${1}" >> $LOG_FILE
  fi
}

# function install_aws {
#     if [[ -z `which aws` ]]; then
#         echo "Installing aws cli"
#         curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
#         sudo installer -pkg AWSCLIV2.pkg -target /
#         rm AWSCLIV2.pkg
#     fi
# }

LOG_FILE="log.out"
echo > $LOG_FILE
for pkg in ${TO_RM_PACKAGES[@]}; do
    brewUninstall $pkg $LOG_FILE
done
for pkg in ${PACKAGES[@]}; do
    brewInstall $pkg $LOG_FILE
done
for pkg in ${CASKS[@]}; do
    brewCaskInstall $pkg $LOG_FILE
done

# rm -r ~/.oh-my-zsh
# sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# mv .zshrc.pre-oh-my-zsh .zshrc

# git
PATH=/usr/local/git/bin:$PATH

# # asdf
# . /usr/local/opt/asdf/libexec/asdf.sh
# asdf plugin-add python
# asdf plugin-add java
# asdf plugin-add nodejs
# asdf plugin-add yarn
# asdf install yarn latest
# asdf install nodejs latest
# asdf install java $(asdf list-all java | grep openjdk | tail -n 1)
# asdf install python latest
# asdf global python latest
# asdf global yarn latest
# asdf global nodejs latest
# asdf global java $(asdf list-all java | grep openjdk | tail -n 1)
