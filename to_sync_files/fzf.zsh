# Setup fzf
# ---------
# ~/.fzf is a dotbot symlink to the fzf submodule in this repo; the binary
# under bin/ is built by ./install via `fzf/install --bin`.
if [[ ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.fzf/shell/key-bindings.zsh"
