# UNAME := $(shell uname)
DOTFILE_PATH := $(CURDIR)
AGENTS_CONFIG := $(HOME)/.agents
HERDR_APP_CONFIG := $(HOME)/.config/herdr-app
HERDR_APP_MODS := tab-gutter sidebar-toggle

.PHONY: help git zsh ni wezterm skills wezterm-wsl herdr herdr-plugin herdr-app herdr-app-check all

$(HOME)/.%: %
	ln -sf $(DOTFILE_PATH)/$^ $@

help:
	@echo "Available targets:"
	@echo "  all           - set up: wezterm (theme, hotkeys); git (credentials, gitignore, aliases); zsh (aliases); ni (node version and package manager); herdr; herdr-app"
	@echo "  skills        - add agent skills"
	@echo "  wezterm-wsl   - configure wezterm on Windows from WSL"
	@echo "  herdr         - link herdr config and plugin"
	@echo "  herdr-app     - link layouts and mods"
	@echo "  herdr-app-check - load the linked mods once and report errors"

git: $(HOME)/.gitconfig $(HOME)/.githelpers $(HOME)/.gitignore

zsh: $(HOME)/.zshrc

ni: $(HOME)/.nirc

wezterm: $(HOME)/.wezterm.lua

herdr: $(HOME)/.config/herdr/config.toml herdr-plugin

$(HOME)/.config/herdr/config.toml: $(DOTFILE_PATH)/herdr/config.toml
	mkdir -p $(HOME)/.config/herdr
	ln -sf $(DOTFILE_PATH)/herdr/config.toml $@

herdr-plugin: $(HOME)/.config/herdr/config.toml
	@if command -v herdr >/dev/null 2>&1; then \
		herdr plugin link $(DOTFILE_PATH)/herdr/plugins/persistent-layout; \
		mkdir -p $(HOME)/.config/herdr/plugins/config/petr.persistent-layout; \
		ln -sfn $(DOTFILE_PATH)/herdr/layouts $(HOME)/.config/herdr/plugins/config/petr.persistent-layout/layouts; \
	else \
		echo "herdr not found; skipping herdr plugin link"; \
	fi

herdr-app: $(HERDR_APP_CONFIG)/layouts/petr.json $(addprefix $(HERDR_APP_CONFIG)/mods/,$(HERDR_APP_MODS))

$(HERDR_APP_CONFIG)/layouts/petr.json: $(DOTFILE_PATH)/herdr-app/layouts/petr.json
	mkdir -p $(dir $@)
	ln -sfn $< $@

$(HERDR_APP_CONFIG)/mods/%: $(DOTFILE_PATH)/herdr-app/mods/%
	mkdir -p $(dir $@)
	ln -sfn $< $@

herdr-app-check: herdr-app
	herdr-app check $(DOTFILE_PATH)/herdr-app/mods/tab-gutter
	herdr-app check $(DOTFILE_PATH)/herdr-app/mods/sidebar-toggle

skills:
	mkdir -p $(AGENTS_CONFIG)
	ln -sfn $(DOTFILE_PATH)/skills $(AGENTS_CONFIG)/skills

wezterm-wsl:
	sed '/return config/i config.default_domain = "WSL:Ubuntu"\
	' wezterm.lua > .wezterm.lua
	mv .wezterm.lua /mnt/c/Users/Slava/.wezterm.lua

all: zsh git wezterm ni skills herdr herdr-app
