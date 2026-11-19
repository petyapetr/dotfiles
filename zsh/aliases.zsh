# Custom
alias lsa='ls -a'
alias cat='bat --plain'

alias oc=opencode
alias mi=micro

# zsh defaults (carry over from oh my zsh)

# These commands should not correct their arguments.
alias cp='nocorrect cp' mv='nocorrect mv' mkdir='nocorrect mkdir'
alias man='nocorrect man' sudo='nocorrect sudo' su='nocorrect su'

if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
