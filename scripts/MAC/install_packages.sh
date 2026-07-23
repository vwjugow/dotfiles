TO_RM_PACKAGES=(
)

PACKAGES=(
    coreutils
    findutils
    git-lfs
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
    tailscale
    tmux
    zeromq
)

CASKS=(
    alfred
    codex
    # claude-code
    iterm2
    rectangle
    spotify
    telegram
    visual-studio-code
    warp
    whatsapp
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

# Homebrew's git bottle links its curl-based helpers (git-remote-http, etc.)
# against the OS-provided libcurl.4.dylib. On some macOS/CLT combinations that
# system curl predates a symbol (curl_global_trace) the git binary expects,
# so any git HTTPS operation dies with "Symbol not found: _curl_global_trace".
# Homebrew's own curl formula has the symbol, so repoint the helpers at it.
function fixGitSystemCurl {
  LOG_FILE=$1
  local system_curl="/usr/lib/libcurl.4.dylib"
  local brew_curl_prefix
  brew_curl_prefix="$(brew --prefix curl 2>/dev/null)"
  [ -n "$brew_curl_prefix" ] || return 0
  local brew_curl="${brew_curl_prefix}/lib/libcurl.4.dylib"
  [ -f "$brew_curl" ] || return 0

  nm -gU "$system_curl" 2>/dev/null | grep -q curl_global_trace && return 0
  nm -gU "$brew_curl" 2>/dev/null | grep -q curl_global_trace || return 0

  local git_core
  git_core="$(brew --prefix git 2>/dev/null)/libexec/git-core"
  [ -d "$git_core" ] || return 0

  for bin in "$git_core"/git-remote-http "$git_core"/git-http-fetch "$git_core"/git-http-push "$git_core"/git-imap-send; do
    [ -f "$bin" ] || continue
    if otool -L "$bin" | grep -q "$system_curl"; then
      echo -e ">>> Repointing ${bin} at brewed curl (system libcurl missing curl_global_trace)" >> "$LOG_FILE"
      install_name_tool -change "$system_curl" "$brew_curl" "$bin"
    fi
  done
}

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

fixGitSystemCurl $LOG_FILE

# rm -r ~/.oh-my-zsh
# sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# mv .zshrc.pre-oh-my-zsh .zshrc


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
