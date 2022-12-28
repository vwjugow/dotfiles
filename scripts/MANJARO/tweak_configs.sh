#/bin/bash

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
