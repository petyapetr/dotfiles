# UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)
AGENTS_CONFIG := $(HOME)/.agents

.PHONY: help git zsh ni wezterm skills wezterm-wsl all

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

help:
	@echo "Available targets:"
	@echo "  all           - set up: wezterm (theme, hotkeys); git (credentials, gitignore, aliases); zsh (aliases); ni (node version and package manager)"
	@echo "  skills        - add agent skills"
	@echo "  wezterm-wsl   - configure wezterm on Windows from WSL"

git: $(HOME)/.gitconfig $(HOME)/.githelpers $(HOME)/.gitignore

zsh: $(HOME)/.zshrc

ni: $(HOME)/.nirc

wezterm: $(HOME)/.wezterm.lua

skills:
	mkdir -p $(AGENTS_CONFIG)
	ln -sfn $(DOTFILE_PATH)/skills $(AGENTS_CONFIG)/skills

wezterm-wsl:
	sed '/return config/i config.default_domain = "WSL:Ubuntu"\
	' wezterm.lua > .wezterm.lua
	mv .wezterm.lua /mnt/c/Users/Slava/.wezterm.lua

all: zsh git wezterm ni skills
