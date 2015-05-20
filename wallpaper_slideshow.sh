#!/bin/bash
#Author: Kyle Agronick
#Email: agronick@gmail.com
 
#Usage: wallpaper_slideshow.sh [FOLDER] [MINUTES]...
#display a new one every [MINUTES] minutes. This script is 
#best used when invoked from an autostart folder. Run with
# --help to display help information.

line()
{
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
}

if [[  $@ == **help** ]] || [[  $@ == **-h** ]]; then  
line
cat << EOF
Usage: $0  [FOLDER] [MINUTES]

Loads a random background image every [MINUTES]
from FOLDER].  Defaults to 2 minutes. Default 
images are the Elementary OS stock background 
images.
 
OPTIONS:
   --bootonly      To load one image and exit
   --makecmd       Make the command to paste into 
   --log	   Write information to the terminal as well as syslog
   --help	   Show this help and exit
EOF
line
exit
fi
 
IS_NUM='^[0-9]+$'  
FOLDER=$1
MINS=2

if [[  $@ == **makecmd** ]]; then  
        echo "How many seconds would you like to wait before starting? Press enter to skip."
	read SECONDS

	CMD="Copy and paste this command: "
	if [[ $SECONDS =~ $IS_NUM ]];
	    then CMD+="sleep $SECONDS;"
	fi

	CMD+="$(readlink -f $0) " 
	if [[  $1 != **makecmd** ]]; then
	CMD+=" $1 "
	fi
	if [[  $2 != **makecmd** ]]; then
	CMD+=" $2 "
	fi
	if [[  $3 != **makecmd** ]]; then
	CMD+=" $3 "
	fi  
	echo -e "\n"
	line
	echo $CMD
	line
	echo -e "\n"
	exit;
fi

FOLDER='/usr/share/backgrounds';
if [[ -d $1 ]];
    then FOLDER=$1
fi

if [[ $1 =~ $IS_NUM ]];
    then MINS=$1 
elif [[ $2 =~ $IS_NUM ]];
    then MINS=$2 
fi

if [[  $@ == **log** ]]; then  
	exec 1> >(logger -s -t $(basename $0)) 2>&1
	echo  “Starting slideshow at a $MINS minute\(s\) interval with images from $FOLDER”
fi
 
IFS=$'\n'
MINS+="m" 
cd "$FOLDER"
while true; do
	FILES=`find ./ -iregex '.*\.\(tga\|jpg\|gif\|png\|jpeg\)$' | shuf` 
	 
	if [ -z "$FILES" ]; then
	    echo "There does not appear to be any image files in $FOLDER"
	    exit
	fi

	for item in $FILES
	do  

	   item=$(readlink -f $item)   
	   gsettings set org.gnome.desktop.background picture-uri "$item" 
	   if [[  $@ == **bootonly** ]]; then  
		exit;
	   fi 
	   if [[  $@ == **log** ]]; then  
		echo “Setting background image to $item”
	   fi
	   sleep $MINS

	done
done
