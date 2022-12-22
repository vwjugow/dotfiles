info "Changing default shell to /usr/bin/zsh ..."
curl -L http://install.ohmyz.sh | sh
chsh -s $(which zsh)
zsh
