#!/bin/bash

[ -f ~/matugen-gum-colors.sh ] && source ~/matugen-gum-colors.sh

clear

printf "\e[38;2;%d;%d;%dm" 0x${GUM_PRIMARY_COLOR:1:2} 0x${GUM_PRIMARY_COLOR:3:2} 0x${GUM_PRIMARY_COLOR:5:2}
figlet "Updates"
printf "\e[0m"
echo

if gum confirm "DO YOU WANT TO START THE UPDATE NOW?" ;then
    echo 
    echo ":: Update started."
elif [ $? -eq 130 ]; then
        exit 130
else
    echo
    echo ":: Update canceled."
    exit;
fi

PACMAN="Update Pacman"
AUR="Update AUR"
ALL="Update ALL"

CHOICE=$(gum choose --limit=1 --header="Which system updates should be made?: " "$PACMAN" "$AUR" "$ALL")

if [ -z "$CHOICE" ]; then
    echo ":: Update canceled."
    exit 130
fi

case "$CHOICE" in
    "$PACMAN")
        sudo pacman -Syu
    ;;
    "$AUR")
        yay --aur
    ;;
    "$ALL")
        yay
    ;;
    *)
        echo ":: Not applying any updates."
    ;;
esac


notify-send "Update complete"
echo 
echo ":: Update complete"
sleep 2
