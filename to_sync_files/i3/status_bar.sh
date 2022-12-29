#!/bin/bash
# shell scipt to prepend i3status with more stuff
i3status --config ~/.i3status.conf | while :
do
    read line
    LG=$(xkblayout-state print %s)
    if [ $LG == "es" ]; then
        dat="[{ \"full_text\": \"LANG: $LG\", \"color\":\"#00FFFF\" },"
    elif [ $LG == "ru" ]; then
        dat="[{ \"full_text\": \"LANG: $LG\", \"color\":\"#FFFFFF\" },"
    else
        dat="[{ \"full_text\": \"LANG: $LG\", \"color\":\"#00008B\" },"
    fi
    echo "${line/[/$dat}" || exit 1
done
