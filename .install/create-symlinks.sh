# Sourced by install.sh. Preflight every existing target before applying links.
config_root=${XDG_CONFIG_HOME:-$HOME/.config}
config_packages=(alacritty hypr fastfetch nvim matugen quickshell)
link_packages=("${config_packages[@]}" starship zsh tmux)
link_targets=()
for package in "${config_packages[@]}"; do
    link_targets+=("$config_root/$package")
done
link_targets+=("$config_root" "$HOME" "$HOME")
command -v stow >/dev/null || { printf 'Install GNU Stow first.\n' >&2; exit 1; }
command -v python3 >/dev/null || { printf 'Install Python first.\n' >&2; exit 1; }
printf 'Checking configuration links for conflicts...\n'
for index in "${!link_packages[@]}"; do
    package=${link_packages[index]}
    target=${link_targets[index]}
    if [[ ! -d "$DOTFILES_ROOT/$package" ]]; then
        printf 'Missing package directory: %s\n' "$package" >&2
        exit 1
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ ! -d "$target" ]]; then
            printf 'Not a directory: %s\n' "$target" >&2
            exit 1
        fi
        # Keep conflict diagnostics and the failing status (install.sh uses pipefail).
        stow --simulate --restow --dir="$DOTFILES_ROOT" --target="$target" "$package" 2>&1 \
            | sed '/^WARNING: in simulation mode so not modifying filesystem\.$/d' >&2
    fi
done
if ! $dry_run; then printf 'Linking configuration...\n'; fi
for index in "${!link_packages[@]}"; do
    package=${link_packages[index]}
    target=${link_targets[index]}
    if $dry_run; then
        printf 'Would link %s into %s\n' "$package" "$target"
    else
        mkdir -p "$target"
        stow --restow --dir="$DOTFILES_ROOT" --target="$target" "$package"
    fi
done
if ! $dry_run; then
    mkdir -p "$HOME/.cache/zsh"
    [[ -e "$HOME/.cache/zsh/.zsh_history" ]] || touch "$HOME/.cache/zsh/.zsh_history"
fi
