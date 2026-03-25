#!/bin/bash

DIRECTORY_SCRIPT=".pkgs/.40"

if [ ! -d "$DIRECTORY_SCRIPT" ]; then
  echo "GAGAL"
  exit
fi

if [ `id -u` != 0 ] ; then
    DE=$(echo $XDG_CURRENT_DESKTOP | grep -E -i -o "xfce|kde|gnome")
else
    DE=$(ls /usr/bin/*session | grep -E -i -o -m 1 "xfce|kde|gnome")
fi

DE_GNOME="gnome"

if [ "${DE,,}" != "${DE_GNOME,,}" ]; then
  echo "Tidak GNOME"
  exit
fi

FOLDER_NAME=$(grep "uuid" $DIRECTORY_SCRIPT/metadata.json | cut -d \" -f4)

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

if [ `id -u` != 0 ] ; then
    USER_HOME="/home/$(whoami)"
fi

DIRECTORY="$USER_HOME/.local/share/gnome-shell"

if [ ! -d "$DIRECTORY" ]; then
  mkdir $DIRECTORY
fi

DIRECTORY_EXTENSION="$DIRECTORY/extensions"
if [ ! -d "$DIRECTORY_EXTENSION" ]; then
  mkdir $DIRECTORY_EXTENSION
fi

EXTENSION="$DIRECTORY/extensions/$FOLDER_NAME/"
if [ ! -d "$EXTENSION" ]; then
  mkdir $EXTENSION
fi

dirfilepath=$DIRECTORY_SCRIPT/*
state=0
for FILE in $dirfilepath
 do
  if [[ -f "$FILE" ]]; then
  	FILECHECK="$EXTENSION${FILE##*/}"
  	if [ ! -f "$FILECHECK" ]; then
	    cp $FILE $EXTENSION
	fi
        state=0
 else
    state=1
    Pesan="Tidak Ditemukan File"
 fi
done
if [ "$(which gnome-extensions)" == "" ];
then
    if [ `id -u` != 0 ] ; then
    	read -s -p "Enter Password for sudo1: " sudoPW
	echo $sudoPW | sudo apt install gnome-extensions -y
    else
    	apt install gnome-extensions -y
    fi
fi

if ! command -v gnome-extensions &> /dev/null
then
    if [ `id -u` != 0 ] ; then
    	read -s -p "Enter Password for sudo2: " sudoPW
	echo $sudoPW | sudo apt install gnome-extensions -y
    else
    	apt install gnome-extensions -y
    fi
fi

$(gnome-extensions enable $FOLDER_NAME)
exit
