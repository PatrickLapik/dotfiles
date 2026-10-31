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

WATCHER="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/watch-installer.py"

case "$CHOICE" in
    "$PACMAN")
        python3 "$WATCHER" -- sudo -B pacman -Syu
    ;;
    "$AUR")
        python3 "$WATCHER" -- yay --sudoflags "-B" --aur
    ;;
    "$ALL")
        python3 "$WATCHER" -- yay --sudoflags "-B"
    ;;
    *)
        echo ":: Not applying any updates."
    ;;
esac

status=$?
if [ "$status" -ne 0 ]; then
    notify-send "Update unsuccessful" "Installer exited with status $status. Check the update terminal."
    echo ":: Update unsuccessful (status $status)."
    read -r -p "Press Enter to close..."
    exit "$status"
fi

notify-send "Update complete"
echo 
echo ":: Update complete"
sleep 2
