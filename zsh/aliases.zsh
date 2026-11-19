# Personal aliases and the directory-listing shortcuts used in shell history.
alias cat='bat --plain' oc=opencode mi=micro
alias l='ls -lah' la='ls -lAh' lsa='ls -lah'

# These commands should not correct their arguments.
alias cp='nocorrect cp' mv='nocorrect mv' mkdir='nocorrect mkdir'
alias man='nocorrect man' sudo='nocorrect sudo' su='nocorrect su'

if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
