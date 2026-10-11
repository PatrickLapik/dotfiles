#!/usr/bin/env bash
# Link the current checkout; package installation is explicitly opt-in.
set -euo pipefail
DOTFILES_ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
export DOTFILES_ROOT
install_packages=false
install_sddm=false
dry_run=false
for option in "$@"; do
    case "$option" in
        --dry-run) dry_run=true ;;
        --packages) install_packages=true ;;
        --sddm) install_sddm=true ;;
        --help|-h)
            cat <<'HELP'
Usage: ./install.sh [--dry-run] [--packages] [--sddm]

Default: link the current dotfiles with Stow and check runtime dependencies.
--dry-run   Show changes and check existing targets without modifying files.
--packages  Install the package lists with pacman and yay first (Arch Linux).
--sddm      Copy the Monochrome theme and default configuration into /usr/share
            and /etc. Does not enable or replace your display manager.

Existing configuration conflicts are reported, never adopted or overwritten.
Runtime helpers expect this checkout at ~/dotfiles.
HELP
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$option" >&2; exit 2 ;;
    esac
done
if [[ "$DOTFILES_ROOT" != "$HOME/dotfiles" ]]; then
    printf 'Keep this checkout at ~/dotfiles; runtime helpers use that location.\n' >&2
    exit 1
fi
if $install_packages; then
    source "$DOTFILES_ROOT/.install/install-packages.sh"
fi
source "$DOTFILES_ROOT/.install/create-symlinks.sh"
if $install_sddm; then
    if $dry_run; then
        printf 'Would install sddm/themes/monochrome and sddm/default.conf.\n'
    else
        sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d
        sudo cp -a "$DOTFILES_ROOT/sddm/themes/monochrome" /usr/share/sddm/themes/
        sudo install -m 644 "$DOTFILES_ROOT/sddm/default.conf" /etc/sddm.conf.d/default.conf
    fi
fi
if ! $dry_run; then
    source "$DOTFILES_ROOT/.install/diagnosis.sh"
fi
