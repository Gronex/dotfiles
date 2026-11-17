WezTerm terminal configuration in `wezterm.lua`, loaded via `dofile` from `~/.config/wezterm/wezterm.lua`.

## Config file lookup (in order)

| # | Location |
|---|----------|
| 1 | `--config-file <path>` CLI argument |
| 2 | `$WEZTERM_CONFIG_FILE` |
| 3 | `$XDG_CONFIG_HOME/wezterm/wezterm.lua` |
| 4 | `~/.config/wezterm/wezterm.lua` ← this repo |
| 5 | `~/.wezterm.lua` |

## Settings in this config

| Option | Value | Purpose |
|--------|-------|---------|
| `initial_cols` | `120` | Window width in columns (default 80) |
| `initial_rows` | `28` | Window height in rows (default 24) |
| `color_scheme` | `'Dracula+'` | Theme (see shortlist below) |
| `default_prog` | `{ '/usr/bin/fish', '-l' }` | Login shell |
| `keys` | `CTRL+Backspace` → sends `CTRL+W` | Let fish do backward-kill-word |

## Common config options (defaults)

| Option | Default | Notes |
|--------|---------|-------|
| `font` | JetBrains Mono + fallbacks | Set via `wezterm.font('Family')` |
| `font_size` | `12.0` | Percent steps via keybindings are 10% |
| `scrollback_lines` | `3500` | |
| `enable_scroll_bar` | `false` | |
| `tab_bar_at_bottom` | `false` | |
| `hide_tab_bar_if_only_one_tab` | `false` | |
| `window_background_opacity` | `1.0` | Below 1.0 needs a compositor |
| `audible_bell` | `'SystemBeep'` | `'Disabled'` to mute |
| `term` | `'xterm-256color'` | `'wezterm'` if terminfo installed |

## Default keybindings (useful subset)

| Keys | Action |
|------|--------|
| `CTRL+SHIFT+T` / `CTRL+SHIFT+W` | New tab / close tab |
| `CTRL+Tab` / `CTRL+SHIFT+Tab` | Next / previous tab |
| `CTRL+SHIFT+1..9` | Jump to tab (9 = last) |
| `CTRL+SHIFT+PageUp/Down` | Move tab left / right |
| `CTRL+SHIFT+Arrow` | Focus pane |
| `CTRL+SHIFT+ALT+"` / `CTRL+SHIFT+ALT+%` | Split vertical / horizontal |
| `CTRL+SHIFT+ALT+Arrow` | Resize pane |
| `CTRL+SHIFT+Z` | Toggle pane zoom |
| `CTRL+SHIFT+X` | Copy mode (`v` select, `y` yank, `/` search, `Esc` exit) |
| `CTRL+SHIFT+F` | Search scrollback |
| `CTRL+SHIFT+Space` | Quick select (URLs, paths, hashes) |
| `CTRL+SHIFT+P` | Command palette |
| `CTRL+SHIFT+L` | Debug overlay |
| `CTRL+SHIFT+R` | Reload config |
| `CTRL+=` / `CTRL+-` / `CTRL+0` | Font bigger / smaller / reset |
| `SHIFT+PageUp/Down` | Scroll by page |
| `ALT+Enter` | Fullscreen |

Tip: `wezterm show-keys --lua` prints all effective bindings (including custom ones) as Lua.

## Color scheme shortlist

`'Dracula'`, `'Catppuccin Mocha'`, `'Tokyo Night'`, `'Nord (base16)'`, `'Gruvbox Dark'`, `'One Half Dark'`, `'Ayu Dark'`, `'rose-pine'`, `'Solarized Dark (base16)'` — full list at wezterm.org/config/color-schemes.html.
