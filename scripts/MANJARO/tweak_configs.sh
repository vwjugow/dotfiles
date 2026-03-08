#/bin/bash

# SSD
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# asdf
. /opt/asdf-vm/asdf.sh
asdf plugin-add python
# asdf plugin-add java
asdf plugin-add nodejs
asdf plugin-add yarn
asdf install yarn latest
asdf install nodejs latest
# asdf install java $(asdf list-all java | grep openjdk | tail -n 1)
asdf install python latest

# Docker
# sudo usermod -a -G docker `whoami`
