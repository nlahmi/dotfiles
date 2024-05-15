-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

---- Start Custom Config ----

-- Gruvbox Material Theme
config.color_scheme = "gruvbox_material_dark_hard"
config.color_schemes = {
    ["gruvbox_material_dark_hard"] = {
        foreground = "#D4BE98",
        background = "#1D2021",
        cursor_bg = "#D4BE98",
        cursor_border = "#D4BE98",
        cursor_fg = "#1D2021",
        selection_bg = "#D4BE98" ,
        selection_fg = "#3C3836",

        ansi = {"#1d2021","#ea6962","#a9b665","#d8a657", "#7daea3","#d3869b", "#89b482","#d4be98"},
        brights = {"#eddeb5","#ea6962","#a9b665","#d8a657", "#7daea3","#d3869b", "#89b482","#d4be98"},
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
config.scrollback_lines = 5000
--config.hide_tab_bar_if_only_one_tab = true

-- Keymaps
config.keys =  {
    { key = "x", mods = "SHIFT|CTRL|ALT", action = act.CloseCurrentPane{ confirm = false } },
}

-- Full screen on startup
wezterm.on("gui-startup", function()
 local tab, pane, window = mux.spawn_window({})
 window:gui_window():maximize()
end)

---- End Custom Config ----

-- and finally, return the configuration to wezterm
return config


