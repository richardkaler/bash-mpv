#!/bin/bash

#NOTE: This is sourced by play.sh - the other script in this repo as of this writing - and I will likely add more to these too. The main thing though is that the second script will not work with its "-d" flag
#unless this script is in path. They can be used a lone but the results are less pleasing that way and the command flags are ineffective. I created these so that everything is compact, reducing the need to
#manage more than one program 

#Also consider that the other script installs mpv for those who do not already have it. This script DOES NOT do that. So... use them both. 

while : 
do
    pushd "$2" >& /dev/null || return 
    echo in "$PWD"
    match() {
    find "$PWD" -type f -iname "*$3*" | wc -l 
}
if [[ $(match "$@") -ne 0 ]]; then 
        screen -d -m find "$PWD" -type f -iname "*$3*" -exec mpv {} \;
        echo finished playing file 
        echo exiting now 
        exit 0 
        popd >& /dev/null || return 
    else 
        echo got nothing - exiting script 
        exit 
    fi
break
done
exit 0 
