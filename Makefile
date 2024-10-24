# UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

git: $(HOME)/.gitconfig $(HOME)/.githelpers $(HOME)/.gitignore
zsh: $(HOME)/.zshrc
wezterm: $(HOME)/.wezterm.lua

wezterm-wsl:
	sed -i '/return config/i config.default_domain = "WSL:Ubuntu"\
	' wezterm.lua
	cp -u wezterm.lua /mnt/c/Users/Slava/.wezterm.lua

all: zsh git wezterm
