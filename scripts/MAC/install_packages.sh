#!/usr/bin/env bash
# Must stay compatible with the macOS system bash 3.2 (no associative arrays).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/detect_arch.sh"

# Brew formulas or casks to remove.
TO_RM_PACKAGES=(
)

# Command line packages, one "brew_name port_name" pair per entry.
# Apple Silicon installs brew_name with Homebrew, Intel installs port_name
# with MacPorts. Use "-" when a package must not come from that manager.
CLI_PACKAGES=(
    "asdf asdf"
    "awscli -"  # MacPorts only has version 1; Intel uses Amazon's installer
    "caddy caddy"
    "coreutils coreutils"
    "curl curl"
    "findutils findutils"
    "gawk gawk"
    "git git"
    "git-lfs git-lfs"
    "gnu-sed gsed"
    "gpg gnupg2"
    "jump jump"
    "lazydocker lazydocker"
    "lazygit lazygit"
    "monit monit"
    "moreutils moreutils"
    "pkgconf pkgconfig"  # MacPorts ports depend on pkgconfig, which conflicts with pkgconf
    "rename rename"
    "tag tag"
    "tailscale tailscale"
    "the_silver_searcher the_silver_searcher"
    "tmux tmux"
    "tree tree"
    "wget wget"
    "zeromq zmq"
)

# Casks come from Homebrew on both architectures.
CASKS=(
    alfred
    alt-tab
    codex
    # claude-code
    iterm2
    keka  # 7zip
    rectangle
    spotify
    telegram
    visual-studio-code
    warp
    whatsapp
)

function install_brew_formula {
  local log_file=$2
  if ! brew list --formula "$1" &> /dev/null; then
    echo -e ">>> Installing ${1} (brew)" | tee -a "$log_file"
    brew install --formula "$1" 2>&1 | tee -a "$log_file"
  else
    echo -e ">>> Already installed: ${1} (brew)" | tee -a "$log_file"
  fi
}

function install_brew_cask {
  local log_file=$2
  if ! brew list --cask "$1" &> /dev/null; then
    echo -e ">>> Installing ${1} (brew cask)" | tee -a "$log_file"
    brew install --cask "$1" 2>&1 | tee -a "$log_file"
  else
    echo -e ">>> Already installed: ${1} (brew cask)" | tee -a "$log_file"
  fi
}

function uninstall_brew_package {
  local log_file=$2
  if brew list "$1" &> /dev/null; then
    echo -e ">>> Uninstalling ${1} (brew)" | tee -a "$log_file"
    brew uninstall "$1" 2>&1 | tee -a "$log_file"
  else
    echo -e ">>> Not installed: ${1} (brew)" | tee -a "$log_file"
  fi
}

# MacPorts prints "Fetching archive" when it uses a prebuilt binary and
# "Configuring" / "Building" when it compiles from source.
function install_port {
  local log_file=$2
  if [ -z "$("$PORT_BIN" -q installed "$1" 2>/dev/null)" ]; then
    echo -e ">>> Installing ${1} (port)" | tee -a "$log_file"
    sudo "$PORT_BIN" -N install "$1" 2>&1 | tee -a "$log_file"
  else
    echo -e ">>> Already installed: ${1} (port)" | tee -a "$log_file"
  fi
}

# Amazon's installer is a universal binary, nothing is compiled.
function install_aws_cli {
  local log_file=$1
  if command -v aws &> /dev/null; then
    echo -e ">>> Already installed: aws cli" | tee -a "$log_file"
    return 0
  fi
  echo -e ">>> Installing aws cli (Amazon installer)" | tee -a "$log_file"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "${tmp_dir}/AWSCLIV2.pkg" \
    && sudo installer -pkg "${tmp_dir}/AWSCLIV2.pkg" -target / 2>&1 | tee -a "$log_file"
  rm -rf "$tmp_dir"
}

# Some ports install a command under a different name than the Homebrew
# formula does. Expose the Homebrew name through a directory that zshrc puts
# first in PATH. One "port_binary command_name" pair per entry.
#   gsed: brew puts GNU sed first as `sed` (gnu-sed/libexec/gnubin); MacPorts'
#         own gnubin directory also holds every coreutils tool, so link only sed.
#   rename.pl: brew's rename formula installs it as `rename`.
PORT_COMMAND_LINKS=(
    "gsed sed"
    "rename.pl rename"
)
PORT_COMMAND_LINKS_DIR="${HOME}/.local/port-links/bin"

function link_port_commands {
  mkdir -p "$PORT_COMMAND_LINKS_DIR"
  local entry port_binary command_name
  for entry in "${PORT_COMMAND_LINKS[@]}"; do
    read -r port_binary command_name <<< "$entry"
    ln -sf "/opt/local/bin/${port_binary}" "${PORT_COMMAND_LINKS_DIR}/${command_name}"
  done
}

# Keep the sudo timestamp fresh while long MacPorts builds run, so the script
# does not stop to ask for the password again. Ends with this script.
function keep_sudo_alive {
  sudo -v || exit 1
  while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" 2> /dev/null || exit
  done 2> /dev/null &
}

# Homebrew's git bottle links its curl-based helpers (git-remote-http, etc.)
# against the OS-provided libcurl.4.dylib. On some macOS/CLT combinations that
# system curl predates a symbol (curl_global_trace) the git binary expects,
# so any git HTTPS operation dies with "Symbol not found: _curl_global_trace".
# Homebrew's own curl formula has the symbol, so repoint the helpers at it.
function fix_git_system_curl {
  local log_file=$1
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
      echo -e ">>> Repointing ${bin} at brewed curl (system libcurl missing curl_global_trace)" | tee -a "$log_file"
      install_name_tool -change "$system_curl" "$brew_curl" "$bin"
    fi
  done
}

LOG_FILE="log.out"
echo > "$LOG_FILE"

if is_apple_silicon; then
  echo ">>> Apple Silicon: command line packages from Homebrew" | tee -a "$LOG_FILE"
else
  echo ">>> Intel: command line packages from MacPorts, casks from Homebrew" | tee -a "$LOG_FILE"
  keep_sudo_alive
fi

for pkg in "${TO_RM_PACKAGES[@]}"; do
  uninstall_brew_package "$pkg" "$LOG_FILE"
done

for entry in "${CLI_PACKAGES[@]}"; do
  read -r brew_name port_name <<< "$entry"
  if is_apple_silicon; then
    [ "$brew_name" = "-" ] || install_brew_formula "$brew_name" "$LOG_FILE"
  else
    [ "$port_name" = "-" ] || install_port "$port_name" "$LOG_FILE"
  fi
done

for pkg in "${CASKS[@]}"; do
  install_brew_cask "$pkg" "$LOG_FILE"
done

if is_apple_silicon; then
  fix_git_system_curl "$LOG_FILE"
else
  install_aws_cli "$LOG_FILE"
  link_port_commands
fi

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
