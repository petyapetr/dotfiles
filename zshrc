# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="petr-dracula"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=~/dotfiles/oh-my-zsh/custom

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git)

source $ZSH/oh-my-zsh.sh

# opencode
export PATH=/home/slava/.opencode/bin:$PATH

# ni
export NI_CONFIG_FILE=$HOME/.nirc

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# mise
eval "$(mise activate zsh)"
