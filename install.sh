#!/bin/bash
source .install/includes/colors.sh
source .install/includes/library.sh
clear

# Set installation mode
mode="live"
if [ ! -z $1 ]; then
    mode="dev"
    echo "IMPORTANT: DEV MODE ACTIVATED. "
    echo "Existing dotfiles folder will not be modified."
    echo "Symbolic links will not be created."
fi
echo -e "${GREEN}"
cat <<"EOF"
 __  __ _    _  ___        __  ____        _    __ _ _           
|  \/  | |  | || \ \      / / |  _ \  ___ | |_ / _(_) | ___  ___ 
| |\/| | |  | || |\ \ /\ / /  | | | |/ _ \| __| |_| | |/ _ \/ __|
| |  | | |__|__   _\ V  V /   | |_| | (_) | |_|  _| | |  __/\__ \
|_|  |_|_____| |_|  \_/\_/    |____/ \___/ \__|_| |_|_|\___||___/
                                                                 
EOF
echo -e "${NONE}"

echo "Version: $version"
echo "by Stephan Raabe 2024"
echo ""
source .install/required.sh
source .install/confirm-start.sh
source .install/paralleldownloads.sh
source .install/yay.sh
source .install/updatesystem.sh
source .install/backup.sh
source .install/preparation.sh
source .install/installer.sh
source .install/remove.sh
source .install/general.sh
source .install/packages/general-packages.sh
source .install/install-packages.sh
source .install/packages/hyprland-packages.sh
source .install/install-packages.sh
source .install/wallpaper.sh
source .install/displaymanager.sh
source .install/issue.sh
source .install/restore.sh
source .install/keyboard.sh
source .install/neovim.sh
source .install/hook.sh
source .install/vm.sh
source .install/copy.sh
source .install/init-pywal.sh
source .install/create-symlinks.sh
source .install/settings.sh
source .install/apps.sh
source .install/gtk.sh
source .install/cleanup.sh
source .install/diagnosis.sh
source .install/reboot.sh
sleep 3
