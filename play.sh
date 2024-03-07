#!/bin/bash 

#NOTE: Tested on Ubuntu Jammy 22.04 LTS. Should work great on any Debian based system. 
#As a cool feature here, this script assumes that some folks will not already have mpv installed, in which case, this code installs it. 

# Notify user that searching for files to play

if [[ "$1" == "-d" ]]; then 
    source playdir.sh #see sister script. Adding even more soon.... Please make sure to put both of these in path. Check names used in these files - both the names of the scripts, and the references to them within. These were tested a few times but not for  
    exit 0 #... production. These also are not scripts you should be using at work because, well... If you can use them for work, that's cool too.  
fi

rootaccess() { sudo -v > /dev/null 2>&1; }

if ! which mpv >/dev/null; then 
    echo "mpv is not installed - attempting install now" 
        if rootaccess; then 
            sudo apt-get install mpv -y #this is an important step and it saves the user a lot of time as many wanting to use this may not already have mpv on their system 
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
        quant="$(find . -maxdepth 1 -type f -iname "$type" | wc -l)"
        quant2="$(find . -maxdepth 1 -type l -iname "$type" | wc -l)"
        if [[ "$quant" -eq 1 ]] || [[ "$quant2" -eq 1 ]]; then  
            search="$(find . -iname "$type" | wc -l)"
            if [[ "$search" -ne 0 ]]; then 
                echo attempting to play media now 
                screen -d -m find . -iname "$type" -exec mpv {} \;  
                echo media now detached in screen session 
            fi
            wait 
            exit 
        fi
    done
fi


## Check for matches and attempt to play media for the current directory
#NOTE: this may seem redundant. However, last segment specifies no argument - and that's the difference 
for type in "${formats[@]}"; do
    match=$(find "$PWD" -maxdepth 1 -type f -iname "$type" -iname "*$1*" 2>/dev/null)
    if [[ -n "$match" ]]; then
        echo "got a match"
        echo "Playing file now. This may take a moment..." 
        #echo -e "Close this window at any time - the media will continue playing\nHowever, entering \"ctrl+c\" terminates the media player"
        #if nohup mpv "$match" 1>simple.out 2>simple.err; then 
        echo initiating screen session to play media in background 
        sleep 1s & 
        if screen -d -m find "$PWD" -maxdepth 1 -type f -iname "$type" -iname "*$1*" -exec mpv {} + | tee 1&>/dev/null \;; then 
            wait 
        fi
        exit 0 
    fi
done

for type in "${formats[@]}"; do
    findct=$(find "$PWD" -maxdepth 1 -type f -iname "$type" -iname "*$1*"| wc -l) 
    if [[ "$findct" -ne 0 ]]; then 
        echo finished - exiting script 
        exit 0 
    fi
done

echo "No valid files found"
echo "Try checking your file extension(s). Exiting script."
exit 0
