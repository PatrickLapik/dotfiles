#!/bin/bash

# Define the base directory
BASE_DIR=~/.config

# Define the subdirectories to be created
SUBDIRS=("wlogout" "hypr" "dunst" "eww" "fastfetch" "alacritty" "rofi" "wal" "waybar")

echo -e "${GREEN}"
figlet "Symlinks"
echo -e "${NONE}"

# Create the base directory if it doesn't exist
if [ ! -d "$BASE_DIR" ]; then
    echo "Base directory $BASE_DIR does not exist. Creating it now..."
    mkdir -p "$BASE_DIR"
else
    echo "Base directory $BASE_DIR already exists."
fi

# Create each subdirectory if it doesn't exist
for SUBDIR in "${SUBDIRS[@]}"; do
    TARGET_DIR="$BASE_DIR/$SUBDIR"
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Subdirectory $TARGET_DIR does not exist. Creating it now..."
        mkdir -p "$TARGET_DIR"
    else
        echo "Subdirectory $TARGET_DIR already exists."
    fi
done

# Execute the stow command for each subdirectory
for SUBDIR in "${SUBDIRS[@]}"; do
    TARGET_DIR="$BASE_DIR/$SUBDIR"
    echo "Creating symlink for $SUBDIR"
    stow -t "$TARGET_DIR" "$SUBDIR"
    echo "Symlink created for $SUBDIR"
done

# Manual commands
stow -t "$BASE_DIR" starship

stow nvim

# Install wallpapers
source wallpaper.sh
