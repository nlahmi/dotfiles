-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

---- Start Custom Config ----

-- Gruvbox Material Theme
config.color_scheme = "gruvbox_material_dark_medium"
config.color_schemes = {
	["gruvbox_material_dark_hard"] = {
		foreground = "#D4BE98",
		background = "#1D2021",
		cursor_bg = "#D4BE98",
		cursor_border = "#D4BE98",
		cursor_fg = "#1D2021",
		selection_bg = "#D4BE98",
		selection_fg = "#3C3836",

		ansi = { "#1d2021", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
		brights = { "#eddeb5", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
	},
	["gruvbox_material_dark_medium"] = {
		foreground = "#D4BE98",
		background = "#282828",
		cursor_bg = "#D4BE98",
		cursor_border = "#D4BE98",
		cursor_fg = "#282828",
		selection_bg = "#D4BE98",
		selection_fg = "#45403d",

		ansi = { "#282828", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
		brights = { "#eddeb5", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
	},
}

-- Hide Windows default bar
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Font
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 14
--config.line_height = 1.2

-- General settings
config.use_dead_keys = false
config.scrollback_lines = 50000
--config.hide_tab_bar_if_only_one_tab = true

-- Keymaps
config.keys = {
	{ key = "x", mods = "SHIFT|CTRL|ALT", action = act.CloseCurrentPane({ confirm = false }) },
	{
		key = "BrowserBack",
		mods = "",
		action = act.SendKey({
			key = "o",
			mods = "CTRL",
		}),
	},
	{
		key = "BrowserForward",
		mods = "",
		action = act.SendKey({
			key = "i",
			mods = "CTRL",
		}),
	},
}

-- Full screen on startup
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- WSL
local wsl_domains = wezterm.default_wsl_domains()
for idx, dom in ipairs(wsl_domains) do
	if dom.name == "WSL:Debian" then
		config.default_domain = "WSL:Debian"
	end
end

-- Disable missing glyphs warning (pops up when using nvim's folding)
config.warn_about_missing_glyphs = false

-- Disable audi-bell (lol)
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 100,
	fade_out_duration_ms = 100,
	target = "CursorColor",
}

---- End Custom Config ----

-- and finally, return the configuration to wezterm
return config
