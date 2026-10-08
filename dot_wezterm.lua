-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Session save/restore: https://github.com/YedPool/Wezurrect
local resurrect = wezterm.plugin.require("https://github.com/YedPool/Wezurrect")

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

-- Registers its own gui-startup handler (restore prompt), so call it before ours
resurrect.setup(config)

-- WezTerm loads the config more than once per launch and each load picked a
-- new session id, leaving blank orphan saves. GLOBAL survives reloads.
wezterm.GLOBAL.resurrect_instance_id = wezterm.GLOBAL.resurrect_instance_id or resurrect.instance_manager.instance_id
resurrect.instance_manager.instance_id = wezterm.GLOBAL.resurrect_instance_id

-- Lets the Claude hook in WSL (~/.claude/hooks/wezterm-pane-session.sh) know
-- its pane and where the Windows home is
config.set_environment_variables = { WSLENV = "WEZTERM_PANE:USERPROFILE/p" }

-- Resurrect only records running programs in "local" panes, so Claude in
-- WSL panes was never resumed. Fill it in from the hook's pane-session file,
-- or for anything else, from the command zsh reports (WEZTERM_CMD in .zshrc).
local pane_tree_mod = require("resurrect.pane_tree")
local create_pane_tree = pane_tree_mod.create_pane_tree
pane_tree_mod.create_pane_tree = function(panes)
	-- The tree drops pane objects, so remember what we need by position
	local pane_ids, pane_cmds = {}, {}
	for _, p in ipairs(panes) do
		local key = p.left .. ":" .. p.top
		pane_ids[key] = p.pane:pane_id()
		pane_cmds[key] = p.pane:get_user_vars().WEZTERM_CMD
	end
	local function fill(node)
		if not node then
			return
		end
		if not node.process and node.domain and node.domain:find("^WSL:") then
			local key = node.left .. ":" .. node.top
			local session = resurrect.process_handlers.read_pane_session(pane_ids[key])
			if session and session.session_id then
				node.process = {
					name = "claude",
					executable = "claude",
					argv = { "claude", "--resume", session.session_id },
					cwd = session.cwd,
				}
			elseif pane_cmds[key] ~= "" then
				node.pending_cmd = pane_cmds[key]
			end
		end
		fill(node.right)
		fill(node.bottom)
	end
	local tree = create_pane_tree(panes)
	fill(tree)
	return tree
end

-- Put the command that was running back at the prompt without running it.
-- Paste instead of typing so zsh won't run multi-line commands either.
local tab_state = resurrect.tab_state
local default_on_pane_restore = tab_state.default_on_pane_restore
local function on_pane_restore(pane_tree)
	default_on_pane_restore(pane_tree)
	if pane_tree.pending_cmd then
		local pane_id = pane_tree.pane:pane_id()
		wezterm.time.call_after(tab_state.process_restore_delay_seconds, function()
			local pane = mux.get_pane(pane_id)
			if pane then
				pane:send_paste(pane_tree.pending_cmd)
			end
		end)
	end
end
tab_state.default_on_pane_restore = on_pane_restore

-- Startup menu: Enter restores the last session (list is newest first),
-- Esc starts fresh. The original menu is still there under "More options".
local instance_manager = resurrect.instance_manager
local show_multi_selector = instance_manager.show_instance_selector
instance_manager.show_instance_selector = function(window, pane, restore_opts, selected)
	-- Alt+R's options captured the original restore function at setup time
	restore_opts.on_pane_restore = on_pane_restore
	-- selected is only passed by the original menu re-showing itself
	if selected then
		return show_multi_selector(window, pane, restore_opts, selected)
	end
	-- Skip this window's own save, it's the blank window we just started in
	local last
	for _, entry in ipairs(instance_manager.list_instances()) do
		if entry.instance_id ~= instance_manager.instance_id then
			last = entry
			break
		end
	end
	if not last then
		return show_multi_selector(window, pane, restore_opts, selected)
	end
	local choices = {
		{ id = last.instance_id, label = "Restore last session: " .. instance_manager.format_instance_summary(last.meta) },
		{ id = "__MORE__", label = "[More options: older sessions, rename, delete, named saves]" },
	}
	window:perform_action(
		act.InputSelector({
			title = "Restore Last Session?",
			description = "Enter = restore, Esc = start fresh",
			choices = choices,
			action = wezterm.action_callback(function(inner_win, inner_pane, id)
				if id == "__MORE__" then
					show_multi_selector(inner_win, inner_pane, restore_opts, {})
				elseif id then
					-- Not public API, but it's the only restore entry point that
					-- also reuses the current window and tombstones the instance
					instance_manager._test.restore_instances({ id }, inner_win, inner_pane, restore_opts)
				end
			end),
		}),
		pane
	)
end

-- Full screen on startup
-- Resurrect may already have spawned windows, only spawn if none exist
wezterm.on("gui-startup", function()
	if #mux.all_windows() == 0 then
		mux.spawn_window({})
	end
	for _, window in ipairs(mux.all_windows()) do
		window:gui_window():maximize()
	end
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
