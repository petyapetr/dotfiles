# UNAME := $(shell uname)
DOTFILE_PATH := $(shell pwd)

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

git: $(HOME)/.gitconfig $(HOME)/.githelpers $(HOME)/.gitignore
zsh: $(HOME)/.zshrc
wezterm: $(HOME)/.wezterm.lua

wezterm-wsl:
	distro_name=$(wsl.exe -l -v | grep Running | grep '*' | awk '{print $2}' | tr -d '\r')
	head -n -2 wezterm > temp && mv temp wezterm
	echo 'config.default_domain = "WSL:$distro_name"\n return config\n' >> wezterm
	cp wezterm /mnt/c/Users/Slava/.wezterm

all: zsh git wezterm
