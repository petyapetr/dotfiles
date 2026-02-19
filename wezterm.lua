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
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.audible_bell = "Disabled"

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
		mods = "SUPER",
		action = act.SpawnCommandInNewTab {domain = "DefaultDomain", cwd = "~"},
	},
	{
		key = "t",
		mods = "SUPER|SHIFT",
		action = act.SpawnTab "CurrentPaneDomain",
	},
	{
		key = "'",
		mods = primary_mod,
		action = act.SplitHorizontal {domain = "CurrentPaneDomain"},
	},
	{
		key = "'",
		mods = primary_mod  .. "|SHIFT",
		action = act.SplitVertical {domain = "CurrentPaneDomain"},
	},
	{
		key = "w",
		mods = primary_mod,
		action = act.CloseCurrentPane {confirm = false},
	},
	{
		key = "[",
		mods = primary_mod,
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "]",
		mods = primary_mod,
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
		key = "UpArrow",
		mods = primary_mod .. "|SHIFT",
		action = act.AdjustPaneSize {"Up", 2},
	},
	{
		key = "DownArrow",
		mods = primary_mod .. "|SHIFT",
		action = act.AdjustPaneSize {"Down", 2},
	},
	{
		key = "LeftArrow",
		mods = primary_mod .. "|SHIFT",
		action = act.AdjustPaneSize {"Left", 2},
	},
	{
		key = "RightArrow",
		mods = primary_mod .. "|SHIFT",
		action = act.AdjustPaneSize {"Right", 2},
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
	{
		key = "1",
		mods = primary_mod,
		action = act.ActivateTab(0),
	},
	{
		key = "2",
		mods = primary_mod,
		action = act.ActivateTab(1),
	},
	{
		key = "3",
		mods = primary_mod,
		action = act.ActivateTab(2),
	},
	{
		key = "4",
		mods = primary_mod,
		action = act.ActivateTab(3),
	},
	{
		key = "5",
		mods = primary_mod,
		action = act.ActivateTab(4),
	},
	{
		key = "6",
		mods = primary_mod,
		action = act.ActivateTab(5),
	},
	{
		key = "7",
		mods = primary_mod,
		action = act.ActivateTab(6),
	},
	{
		key = "8",
		mods = primary_mod,
		action = act.ActivateTab(7),
	},
	{
		key = "9",
		mods = primary_mod,
		action = act.ActivateTab(8),
	},
	{
		key = "0",
		mods = primary_mod,
		action = act.ActivateTab(9),
	},
	{
		key = "n",
		mods = primary_mod,
		action = act.SpawnCommandInNewWindow {domain = "DefaultDomain", cwd = "~"},
	},
}

return config
