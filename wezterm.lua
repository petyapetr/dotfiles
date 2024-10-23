local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font("Unifont")
config.cell_width = 0.5
config.font_size = 18

config.window_decorations = "RESIZE"

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
-- config.show_close_tab_button_in_tabs = true

config.window_background_opacity = 0.95
config.macos_window_background_blur = 2

config.color_scheme_dirs = {"~/dotfiles/wezterm/colors"}
config.color_scheme = "Dracula (Official)"

config.hide_tab_bar_if_only_one_tab = false

config.keys = {
	{
		key = "t",
		mods = "CTRL",
		action = act.SpawnTab "CurrentPaneDomain"
	},
	{
		key = "t",
		mods = "CMD|SHIFT",
		action = act.SpawnCommandInNewTab { cwd = "~" }
	},
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = act.SpawnCommandInNewTab { cwd = "~" }
	},
	{
		key = ";",
		mods = "CMD",
		action = act.SplitVertical { domain = "CurrentPaneDomain" }
	},
	{
		key = ";",
		mods = "CTRL",
		action = act.SplitVertical { domain = "CurrentPaneDomain" }
	},
	{
		key = "'",
		mods = "CMD",
		action = act.SplitHorizontal { domain = "CurrentPaneDomain" }
	},
	{
		key = "'",
		mods = "CTRL",
		action = act.SplitHorizontal { domain = "CurrentPaneDomain" }
	},
	{
		key = "w",
		mods = "CMD",
		action = act.CloseCurrentPane { confirm = false }
	},
	{
		key = "w",
		mods = "CTRL",
		action = act.CloseCurrentPane { confirm = false }
	},
	{
		key = "j",
		mods = "CMD",
		action = act.ActivateTabRelative(-1)
	},
	{
		key = "j",
		mods = "CTRL",
		action = act.ActivateTabRelative(-1)
	},
	{
		key = "l",
		mods = "CMD",
		action = act.ActivateTabRelative(1)
	},
	{
		key = "l",
		mods = "CTRL",
		action = act.ActivateTabRelative(1)
	},
	{
		key = "i",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection "Up"
	},
	{
		key = "i",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection "Up"
	},
	{
		key = "k",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection "Down"
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection "Down"
	},
	{
		key = "j",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection "Left"
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection "Left"
	},
	{
		key = "l",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection "Right"
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection "Right"
	},
}

return config