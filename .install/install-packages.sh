# Sourced by install.sh only with --packages.
pacman_packages=()
aur_packages=()
for manifest in general hyprland; do
    source "$DOTFILES_ROOT/.install/packages/$manifest-packages.sh"
    pacman_packages+=("${packagesPacman[@]}")
    aur_packages+=("${packagesYay[@]}")
done
if $dry_run; then
    printf 'Would run: sudo pacman -Syu --needed'
    printf ' %q' "${pacman_packages[@]}"
    printf '\nWould run: yay -S --needed'
    printf ' %q' "${aur_packages[@]}"
    printf '\n'
else
    command -v pacman >/dev/null || { printf 'Package installation requires Arch Linux.\n' >&2; exit 1; }
    command -v yay >/dev/null || { printf 'Install yay before using --packages.\n' >&2; exit 1; }
    sudo pacman -Syu --needed "${pacman_packages[@]}"
    yay -S --needed "${aur_packages[@]}"
fi
