# UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

git: $(HOME)/.gitconfig $(HOME)/.githelpers $(HOME)/.gitignore
zsh: $(HOME)/.zshrc
wezterm: $(HOME)/.wezterm.lua

wezterm-wsl:
	head -n -2 wezterm.lua > temp && mv temp wezterm.lua
	echo '\nconfig.default_domain = "WSL:Ubuntu"\n\nreturn config\n' >> wezterm.lua
	cp -u wezterm.lua /mnt/c/Users/Slava/.wezterm.lua

all: zsh git wezterm
