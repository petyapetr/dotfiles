# Your petr-dracula colors and two-line layout, without OMZ helpers.
export LSCOLORS='Gxfxcxdxbxegedabagacad'

# One Git status call supplies branch, changes, and upstream counts.
# Untracked files and dirty submodule contents stay ignored.
update_git_prompt() {
  git_prompt=' '
  local output line branch oid state='%F{green}OK' ahead=0 behind=0
  local -a fields
  output=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch \
    --untracked-files=no --ignore-submodules=dirty 2>/dev/null) || return 0
  for line in "${(@f)output}"; do
    case "$line" in
      '# branch.head '*) branch="${line#\# branch.head }" ;;
      '# branch.oid '*) oid="${line#\# branch.oid }" ;;
      '# branch.ab '*)
        fields=(${=line})
        ahead="${fields[3]#+}"
        behind="${fields[4]#-}" ;;
      [12u]' '*) state='%F{yellow}*' ;;
    esac
  done
  [[ "$branch" == '(detached)' ]] && branch="${oid[1,7]}"
  # Escape percent signs in branch names because zsh interprets prompt codes.
  git_prompt=" %F{cyan}(%B${branch//\%/%%} ${state}%F{cyan}%b)%f "
  (( behind )) && git_prompt+="${behind}%F{cyan}↓%f"
  (( ahead )) && git_prompt+="${ahead}%F{cyan}↑%f "
  return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd update_git_prompt
setopt prompt_subst
PROMPT='%F{blue}%B%~%b${git_prompt}%f[%T]
%B%_>%b '
