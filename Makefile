# UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

help:
	@echo "Available targets:"
	@echo "  all      			— sets up wezterm (theme, hotkeys); git (credentials, gitignore, aliases); zsh (aliases); ni (node version and package manager)"
	@echo "  wezterm-wsl    - sets up wezterm on Windows from WSL"

git: $(HOME)/.gitconfig $(HOME)/.githelpers $(HOME)/.gitignore

zsh: $(HOME)/.zshrc

ni: $(HOME)/.nirc

wezterm: $(HOME)/.wezterm.lua

wezterm-wsl:
	sed '/return config/i config.default_domain = "WSL:Ubuntu"\
	' wezterm.lua > .wezterm.lua
	mv .wezterm.lua /mnt/c/Users/Slava/.wezterm.lua

all: zsh git wezterm ni
