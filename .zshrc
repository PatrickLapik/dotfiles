# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# History
HISTFILE=~/.cache/zsh/.zsh_history
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Android environment variables
export ANDROID_HOME=$HOME/android-sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH

# Env
export PAGER=more

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(fzf --zsh)"

alias cd="z"
alias c="clear"
alias ls="ls --color"
alias cts="~/dotfiles/scripts/create-tmux-session.sh" # Create tmux session command
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'

stty -ixon
