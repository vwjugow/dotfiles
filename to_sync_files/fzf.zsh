# Setup fzf
# ---------
if [[ ! "$PATH" == */home/kuvic/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/kuvic/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/kuvic/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/kuvic/.fzf/shell/key-bindings.zsh"
