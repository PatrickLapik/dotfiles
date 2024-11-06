#!/bin/bash

# Define the base directory
BASE_DIR=~/.config
CURRENT_DIR="$HOME/dotfiles"


# Define the subdirectories to be created
SUBDIRS=("wlogout" "hypr" "dunst" "eww" "fastfetch" "alacritty" "rofi" "wal" "waybar" "nvim")

echo -e "${GREEN}"
figlet "Symlinks"
echo -e "${NONE}"

# Create the base directory if it doesn't exist
if [ ! -d "$BASE_DIR" ]; then
    echo ":: Base directory $BASE_DIR does not exist. Creating it now..."
    mkdir -p "$BASE_DIR"
else
    echo ":: Base directory $BASE_DIR already exists."
fi

# Create each subdirectory if it doesn't exist
for SUBDIR in "${SUBDIRS[@]}"; do
    TARGET_DIR="$BASE_DIR/$SUBDIR"
    if [ ! -d "$TARGET_DIR" ]; then
        echo ":: Subdirectory $TARGET_DIR does not exist. Creating it now..."
        mkdir -p "$TARGET_DIR"
    else
        echo ":: Subdirectory $TARGET_DIR already exists."
    fi
done

# Execute the stow command for each subdirectory
for SUBDIR in "${SUBDIRS[@]}"; do
    TARGET_DIR="$BASE_DIR/$SUBDIR"
    echo ":: Creating symlink for $SUBDIR"
    stow -t "$TARGET_DIR" -d "$CURRENT_DIR" "$SUBDIR"
    echo "Symlink created for $SUBDIR"
done

# Manual commands
stow -t "$BASE_DIR" -d "$CURRENT_DIR" starship

# Copy themes to sddm themes folder because it doesn't work any other way rn
read -p "Copy sddm themes from dotfiles to default sddm themes folder? [y/N]: " copy_themes

case "$copy_themes" in 
    [Yy]* )
        echo "Copying themes from dotfiles to default sddm themes folder."
        sudo cp -r ~/dotfiles/sddm/themes/* /usr/share/sddm/themes
        ;;
    * )
        echo "Proceeding without copying the themes"
        ;;
esac

if [ ! -e "/etc/sddm.conf.d" ]; then
    sudo ln -s ~/dotfiles/sddm/default.conf /etc/sddm.conf.d
fi

# Add .zshrc symlink
if [ -e "~/.zshrc" ]; then
    echo ":: Config for zsh already exists. In order to make a symlink it has to be removed..."
    read -p "Create a back up of a .zshrc file? [y/N]: " create_backup
    case "$create_backup" in
        [Yy]* )
            mv ~/.zshrc ~/.zshrc.backup
            echo ":: Created a .zshrc backup in ~/.zshrc.backup"
            ;;
        * )
            echo ":: Proceeding without a backup"
            ;;
    esac

    echo ":: Creating symlink for .zshrc file"
    ln -s ~/dotfiles/.zshrc ~/.zshrc 
    echo "Symlink created for .zshrc file"
fi

if [ ! -e "~/.cache/zsh/.zsh_history" ]; then
    read -p ":: No zsh command cache file present. Create the file? [y/N]: " create_cache
    case "$create_cache" in
        [Yy]* )
            mkdir -p ~/.cache/zsh
            touch ~/.cache/zsh/.zsh_history
            echo ":: Created cache file in ~/.cache/zsh/.zsh_history"
            ;;
        * )
            echo ":: Proceeding without creating the cache file"
    esac
fi

# Install wallpapers
source wallpaper.sh
