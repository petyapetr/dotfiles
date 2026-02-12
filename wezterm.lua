local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font("Unifont")
config.cell_width = 0.5
config.font_size = 18

config.window_decorations = "RESIZE"

local target = wezterm.target_triple
local is_windows = target:find("windows") ~= nil
local is_macos = target:find("darwin") ~= nil
local primary_mod = is_macos and "CMD" or "CTRL"

config.enable_tab_bar = true
-- config.use_fancy_tab_bar = false
-- config.show_close_tab_button_in_tabs = true

wezterm.on("new-tab-button-click", function(window, pane)
		window:perform_action(wezterm.action.SpawnCommandInNewTab({cwd = wezterm.home_dir}), pane)
		return false
	end
)

config.window_background_opacity = 0.95
config.macos_window_background_blur = 2

config.color_scheme_dirs = {"~/dotfiles/wezterm/colors"}
config.color_scheme = "Dracula (Official)"

config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = "NeverPrompt"

if is_windows then
	config.window_decorations = "RESIZE | TITLE"
end

config.keys = {
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "t",
		mods = "CMD|SHIFT",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "t",
		mods = "CMD",
		action = act.SpawnTab "CurrentPaneDomain",
	},
	{
		key = "t",
		mods = primary_mod .. "|SHIFT",
		action = act.SpawnCommandInNewTab { domain = "DefaultDomain", cwd = "~"},
	},
	{
		key = ";",
		mods = primary_mod,
		action = act.SplitVertical { domain = "CurrentPaneDomain" },
	},
	{
		key = "'",
		mods = primary_mod,
		action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
	},
	{
		key = "w",
		mods = primary_mod,
		action = act.CloseCurrentPane { confirm = false },
	},
	{
		key = "j",
		mods = "ALT",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "l",
		mods = "ALT",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "UpArrow",
		mods = primary_mod,
		action = act.ActivatePaneDirection "Up",
	},
	{
		key = "DownArrow",
		mods = primary_mod,
		action = act.ActivatePaneDirection "Down",
	},
	{
		key = "LeftArrow",
		mods = primary_mod,
		action = act.ActivatePaneDirection "Left",
	},
	{
		key = "RightArrow",
		mods = primary_mod,
		action = act.ActivatePaneDirection "Right",
	},
	{
		key = "c",
		mods = primary_mod .. "|SHIFT",
		action = act.CopyTo "Clipboard",
	},
	{
		key = "v",
		mods = primary_mod,
		action = act.PasteFrom "Clipboard",
	},
}

return config
