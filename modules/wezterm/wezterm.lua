local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- window
config.initial_cols = 120
config.initial_rows = 28

-- theme
config.color_scheme = 'Dracula+'

-- shell
config.default_prog = { '/usr/bin/fish', '-l'}

-- key bindings
local act = wezterm.action

config.keys = {
	{ key = 'Backspace', mods = 'CTRL', action = act.SendKey {key = 'w', mods = 'CTRL'}	}
}

return config
