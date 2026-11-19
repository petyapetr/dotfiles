# Vite+ is available to interactive shells, scripts, and zsh -c commands.
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/vite-plus/env" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/vite-plus/env"
fi
