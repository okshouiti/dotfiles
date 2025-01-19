local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

config.automatically_reload_config = true

-- This is where you actually apply your config choices
config.default_prog = { 
	wezterm.home_dir .. '/scoop/apps/nu/current/nu.exe',
	'--config',
	wezterm.home_dir .. '/OneDrive/repo/dotfiles/nushell/config.nu'
}
config.font_size = 14.0
config.use_ime = true
config.window_background_opacity = 0
config.win32_system_backdrop = 'Acrylic'
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.window_background_gradient = {
    colors = { "#000000" },
}

config.keys = {
    { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
    { key = 'q', mods = 'ALT', action = act.CloseCurrentTab { confirm = true } },
    { key = 'a', mods = 'ALT', action = act.ActivateTabRelative(-1) },
    { key = 'd', mods = 'ALT', action = act.ActivateTabRelative(1) },
    { key = 'e', mods = 'ALT',action = act.SpawnTab 'CurrentPaneDomain',
  },
}
config.mouse_bindings = {
    -- 右クリックでクリップボードから貼り付け
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = act.PasteFrom 'Clipboard',
    },
}

 local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
 local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
 local background = "#5c6d74"
 local foreground = "#FFFFFF"
   local edge_background = "none"
 if tab.is_active then
   background = "#ae8b2d"
   foreground = "#FFFFFF"
 end
   local edge_foreground = background
 local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
 return {
     { Background = { Color = edge_background } },
     { Foreground = { Color = edge_foreground } },
     { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
   { Text = title },
     { Background = { Color = edge_background } },
     { Foreground = { Color = edge_foreground } },
     { Text = SOLID_RIGHT_ARROW },
 }
end)

return config

