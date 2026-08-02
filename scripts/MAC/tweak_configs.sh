ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents

# Free up Ctrl+Left/Ctrl+Right (Mission Control "Move left/right a space")
# so they're available for app/vim tab-switching shortcuts instead.
# Requires a logout/reboot to take effect (killing Dock is not enough).
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 '<dict><key>enabled</key><false/></dict>'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 '<dict><key>enabled</key><false/></dict>'
