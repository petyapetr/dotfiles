# History persists across terminals. A leading space keeps a command out of it.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history share_history hist_ignore_space hist_ignore_dups
setopt hist_expire_dups_first hist_verify

# Native directory navigation and spelling correction.
setopt auto_cd auto_pushd pushd_ignore_dups correct_all

# Completion: ignore case, allow partial matches, select with repeated Tab.
# Drop OMZ completion paths inherited from an existing terminal.
fpath=("${(@)fpath:#${ZSH:-$HOME/.oh-my-zsh}/*}")
unset ZSH ZSH_CUSTOM
autoload -Uz compinit
compinit
zmodload zsh/complist
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
setopt complete_in_word always_to_end

# Standard editing keys; Up/Down search history using what you've typed.
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
bindkey '^X^E' edit-command-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Resolve the ~/.zshrc symlink to find this checkout.
_dotfiles_dir="${${(%):-%x}:A:h}"
source "$_dotfiles_dir/zsh/aliases.zsh"
source "$_dotfiles_dir/zsh/petr-dracula.zsh"
unset _dotfiles_dir

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# mise
eval "$(mise activate zsh)"

# Vite+ bin (https://viteplus.dev)
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/vite-plus/env" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/vite-plus/env"
fi

# gitu tui
export GITU_SHOW_EDITOR=micro
