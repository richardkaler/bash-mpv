#!/bin/bash

# Notify user that searching for files to play

if [[ "$1" == "-d" ]]; then
    source playdir.sh
    exit 0
fi
#shellcheck disable=SC2001
arg="$(echo "$1" |sed 's%\./%%')"

rootaccess() { sudo -v > /dev/null 2>&1; }


if ! which mpv >/dev/null; then
    echo "mpv is not installed - attempting install now"
    if rootaccess; then
        sudo apt-get install mpv -y
    else
        echo "log in as a user with root access to install mpv"
        echo "NOTE: $(whoami) does not have required root permissions"
        exit 1
    fi
else
    echo "mpv is already installed - proceeding with script"
fi

formats=(
    "*flac"
    "*.mp4"
    "*.avi"
    "*.mkv"
    "*.mov"
    "*.wmv"
)

summary() {
    echo "Plays files in the current directory"
    echo "Ex: play.sh [file]"
    echo "NOTE: You may be asking for trouble if multiple files match your string"
    echo "File must have a valid extension: mpv, avi, mp4, wmv, flac, mov"
}

# Display summary if the only argument is "-h"
if [[ "$1" == "-h" ]]; then
    summary
    exit 0
    #trigger the second conditional if there is no arg
elif [[ -z "$1" ]]; then
    for type in "${formats[@]}"
    do
        quant="$(find . -maxdepth 1 -type f -iname "$type" | wc -l)" #Prevents the opening of several simultaneous files which would jam  up a host
        quant2="$(find . -maxdepth 1 -type l -iname "$type" | wc -l)" #Does the same thing but checks for symbolic links instead of just files
        if [[ "$quant" -eq 1 ]] || [[ "$quant2" -eq 1 ]]; then
            search="$(find . -iname "$type" | wc -l)"
            if [[ "$search" -ne 0 ]]; then
                echo attempting to play media now
                screen -S mpvplay -dm find . -iname "$type" -exec mpv {} + &
                echo media now detached in screen session
            fi
            exit
        fi
    done
fi


## Check for matches and attempt to play media for the current directory
#NOTE: this may seem redundant. However, last segment specifies no argument - and that's the difference
for type in "${formats[@]}"; do
    match=$(find .  -maxdepth 1 -type f -iname "$type" -iname "*$arg*" 2>/dev/null || \
        find .  -maxdepth 1 -type f -iwholename "$type" -iname "*$arg*" 2>/dev/null)
    if [[ -n "$match" ]]; then
        echo "got a match"
        echo "Playing file now. This may take a moment..."
        echo initiating screen session to play media in background
        sleep 1s &
        if screen -S "$arg" -dm find  -maxdepth 1 -type f -iname "$type" -iname "*$arg*" -exec mpv {} 2>/dev/null +; then
            wait
        else
            screen -S "$arg" -dm find -maxdepth 1 -type f -iwholename "$type" -wholename "*$arg*" -exec mpv {} 2>/dev/null +;
        fi
        exit 0
    fi
done

for type in "${formats[@]}"; do
    findct=$(find "$PWD" -maxdepth 1 -type f -iname "$type" -iname "*$arg*"| wc -l)
    if [[ "$findct" -ne 0 ]]; then
        echo finished - exiting script
        exit 0
    fi
done

echo "No valid files found"
echo "Try checking your file extension(s). Exiting script."
exit 0
