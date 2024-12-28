#!/bin/bash -e

arg="$1"
searchterm="$(echo "$1" | sed 's%\./%%')"

shortname="$(basename "$0")"

if [[ -z "$arg" ]]; then
    echo "Error - an argument is required"
    echo "Ex) $shortname [media]"
    exit 1
fi

summary() {
    echo "Plays files in the current directory"
    echo "Ex: play.sh [file]"
    echo "Tip: script plays one file at a time - limit your search"
    echo "File must have a valid extension: mkv, avi, mp4, wmv, flac, mov"
}

if [[ "$1" =~ (h|-h|--h|-help|--help|help)$ ]]; then
    summary
    exit 0
fi

rootaccess() { sudo -v > /dev/null 2>&1; }

mpvcheck="$(command -v mpv)"

if [[ -z "$mpvcheck" ]]; then
 echo "mpv is not installed - attempting install now"
    if rootaccess; then
        sudo apt-get install mpv -y
    else
        echo "log in as a user with root access to install mpv"
        echo "NOTE: $USER has insufficient permissions"
        exit 1
    fi

else
    echo "mpv is already installed - proceeding with script"
fi

search() { find "$PWD" -maxdepth 1 -type f -iname "*$searchterm*" | grep -iE '\.(avi|\.mp4|\.mkv|\.flac|\.wmv|\.mov)$'; }

filecount="$(search | wc -l)"

if [[ "$filecount" -eq 0 ]]; then
    echo "No valid media found - check file integrity or narrow search"
    exit 0
fi


screenplay() { screen -S mpvplay -dm find "$PWD" -maxdepth 1 -iname "*$searchterm*" -exec mpv {} +; }

echo "Opening file with mpv now..."

if screenplay; then
     exit 0
else
    echo "Error - failed to launch media"
exit 1
fi

