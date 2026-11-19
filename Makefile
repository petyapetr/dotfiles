# UNAME := $(shell uname)
DOTFILE_PATH := $(CURDIR)
AGENTS_CONFIG := $(HOME)/.agents
HERDR_APP_CONFIG := $(HOME)/.config/herdr-app
HERDR_APP_MODS := tab-gutter sidebar-toggle default-workspace
MICRO_CONFIG := $(if $(XDG_CONFIG_HOME),$(XDG_CONFIG_HOME),$(HOME)/.config)/micro
MICRO_PLUGINS := filemanager quoter fzfinder

.PHONY: help git zsh wezterm micro micro-plugins skills wezterm-wsl herdr-app all

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

help:
	@echo "Available targets:"
	@echo "  all           - set up: wezterm (theme, hotkeys); git (credentials, gitignore, aliases); zsh (aliases, Vite+ environment); micro; herdr-app"
	@echo "  micro         - link micro settings and keybindings"
	@echo "  micro-plugins - link micro config and install plugins (requires micro and network)"
	@echo "  skills        - add agent skills"
	@echo "  wezterm-wsl   - configure wezterm on Windows from WSL"
	@echo "  herdr-app     - link layouts and mods, merge custom keys"
	@echo "  herdr-app-keys - merge custom key remappings (requires node)"

git: $(HOME)/.gitconfig $(HOME)/.githelpers $(HOME)/.gitignore

zsh: $(HOME)/.zshrc $(HOME)/.zshenv

wezterm: $(HOME)/.wezterm.lua

micro:
	mkdir -p "$(MICRO_CONFIG)"
	ln -sfn "$(DOTFILE_PATH)/micro/settings.json" "$(MICRO_CONFIG)/settings.json"
	ln -sfn "$(DOTFILE_PATH)/micro/bindings.json" "$(MICRO_CONFIG)/bindings.json"

micro-plugins: micro
	micro -config-dir "$(MICRO_CONFIG)" -plugin install $(MICRO_PLUGINS)

herdr-app: $(HERDR_APP_CONFIG)/layouts/petr.json $(addprefix $(HERDR_APP_CONFIG)/mods/,$(HERDR_APP_MODS)) herdr-app-keys

.PHONY: herdr-app-keys
herdr-app-keys:
	node "$(DOTFILE_PATH)/herdr-app/merge-keys.mjs" "$(DOTFILE_PATH)/herdr-app/key-remappings.json" "$(HERDR_APP_CONFIG)/keys.json"

$(HERDR_APP_CONFIG)/layouts/petr.json: $(DOTFILE_PATH)/herdr-app/layouts/petr.json
	mkdir -p $(dir $@)
	ln -sfn $< $@

$(HERDR_APP_CONFIG)/mods/%: $(DOTFILE_PATH)/herdr-app/mods/%
	mkdir -p $(dir $@)
	ln -sfn $< $@

skills:
	mkdir -p $(AGENTS_CONFIG)
	ln -sfn $(DOTFILE_PATH)/skills $(AGENTS_CONFIG)/skills

wezterm-wsl:
	sed '/return config/i config.default_domain = "WSL:Ubuntu"\
	' wezterm.lua > .wezterm.lua
	mv .wezterm.lua /mnt/c/Users/Slava/.wezterm.lua

all: zsh git wezterm micro skills herdr-app
