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
   --wait	   Sleep [MINUTES] minutes before changing to the first image
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
	CMD="Copy and paste this command: " 
	CMD+="$(readlink -f $0) " 

	cmds=($1 $2 $3 $4 $5) 
	for i in ${cmds[@]}; do
		if [[  $i != **makecmd** ]]; then
		CMD+=" $i "
		fi 
	done

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

cd "$FOLDER"

if [[  $@ == **wait** ]]; then  
	sleep "$MINS""m"
fi

function do_exit()
{ 
    if [[  $@ == **log** ]]; then  
		echo "Exiting..."
		pkill "logger -s -t $(basename $0)"
	fi 
	exit;
}
trap do_exit EXIT TERM

ERRORCOUNT=0
while true; do
	FILES=`find ./ -iregex '.*\.\(tga\|jpg\|gif\|png\|jpeg\)$' | shuf` 
	 
	if [ -z "$FILES" ]; then
	    echo "There does not appear to be any image files in $FOLDER"
	    exit
	fi

	for item in $FILES
	do  

	   item=$(readlink -f $item)   
	   OUTPUT=$(gsettings set org.gnome.desktop.background picture-uri "$item" 2>&1) 
       if [ ${#OUTPUT} -gt 3 ]; then
            ((ERRORCOUNT++)) 
            
            if [  $(($ERRORCOUNT * $MINS))  -gt 10 ]; then
                do_exit
            fi 
       else 
	       if [[  $@ == **log** ]]; then  
		    echo “Set background image to $item”
	       fi
            ERRORCOUNT=0
       fi 
	   if [[  $@ == **bootonly** ]]; then 
		do_exit
	   fi 
	   sleep "$MINS""m"

	done
done  
