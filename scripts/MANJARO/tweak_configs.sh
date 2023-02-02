#/bin/bash

# Spotify conf
SPOTIFY_FOLDER="$HOME/.config/spotify"
SPOTIFY_PREFS_FILE="${SPOTIFY_FOLDER}/prefs"
if [[ ! -d $SPOTIFY_FOLDER ]] || [[ ! -f $SPOTIFY_PREFS_FILE ]]; then
    mkdir -p $SPOTIFY_FOLDER
    touch $SPOTIFY_PREFS_FILE
fi
grep -e 'storage.size=\S\+' $SPOTIFY_PREFS_FILE
if [[ $? == 0 ]]; then
    sed -i -e 's/storage.size=\S\+/storage.size=1640/' $SPOTIFY_PREFS_FILE
else
    echo 'storage.size=1640' >> $SPOTIFY_PREFS_FILE
fi

# SSD
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# asdf
. /opt/asdf-vm/asdf.sh
asdf plugin-add python
asdf plugin-add java
asdf plugin-add nodejs
asdf plugin-add yarn
asdf install yarn latest
asdf install nodejs latest
asdf install java $(asdf list-all java | grep openjdk | tail -n 1)
asdf install python latest

# Docker
sudo usermod -a -G docker `whoami`
