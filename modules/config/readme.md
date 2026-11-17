Standalone config files referenced by other modules (module is disabled in `dotfiles list`; nothing installs directly).

# oh-my-posh reference

Theme: `oh-my-posh.toml` (schema version 4). Loaded by `modules/bash/bashrc.bash`:

```bash
eval "$(oh-my-posh init bash --config "$(dirname "${BASH_SOURCE[0]}")/../config/oh-my-posh.toml")"
```

Without `--config` (or `POSH_THEME`), the built-in `jandedobbeleer` theme is used.

## Init per shell

| Shell | Init line |
|-------|-----------|
| bash / zsh | `eval "$(oh-my-posh init bash --config cfg)"` |
| fish | `oh-my-posh init fish --config cfg \| source` |
| pwsh | `(& oh-my-posh init pwsh --config cfg) -OutString \| Invoke-Expression` |

## Top-level keys in this theme

| Key | Value | Meaning |
|-----|-------|---------|
| `final_space` | `true` | Trailing space after the last segment |
| `pwd` | `"osc7"` | Emit OSC 7 escape so the terminal can track cwd |
| `[upgrade]` | notice every `24h` | Upgrade notice on, `auto = false`, from CDN |

## Theme structure (2 blocks)

| Segment | Shows | Notable options |
|---------|-------|-----------------|
| `executiontime` | Last command duration | `threshold = 150` (default 500), `style = "austin"` |
| `git` | Branch, ahead/behind, working/staging, stash | `fetch_status`, `fetch_upstream_icon`, branch truncated to 25 |
| `python` `go` `node` `ruby` `java` `julia` `php` `dotnet` | Version + venv | `fetch_version` (hidden when not in a project) |
| `battery` | Percentage + icon | Foreground color per state (charging/discharging/full) |
| `root` | `ROOT` badge | Only renders when elevated |
| `text` | Username | Free-form template segment |
| `path` | Current path | `style = "agnoster"` (default); others: `full`, `folder`, `short`, `fish`, `mixed`, `agnoster_short`, `powerlevel` |

## Template properties used here

| Property | Segment | Content |
|----------|---------|---------|
| `.Env` | any | Environment map, e.g. `{{ .Env.USER }}` |
| `.UserName` `.Host` | text | User / hostname |
| `.Path` `.Folder` | path | Full path / current folder |
| `.Full` `.Major` `.Minor` `.Patch` `.Venv` `.Error` | languages | Version info and venv name |
| `.HEAD` `.Branch` `.UpstreamIcon` `.BranchStatus` | git | Ref and upstream state |
| `.Ahead` `.Behind` `.Working.String` `.Staging.String` `.StashCount` | git | Divergence and dirt |
| `.FormattedMs` | executiontime | Human-readable duration |
| `.Percentage` `.State` `.Icon` | battery | Battery info |

## Template syntax

| Syntax | Purpose |
|--------|---------|
| `{{ if .X }}…{{ else }}…{{ end }}` | Conditional rendering |
| `gt` `eq` `and` `or` `not` | Comparisons / logic |
| `{{ trunc 25 .Branch }}` | Truncate string |
| `round` `replace` `replaceP` `url` `secondsRound` | Formatting helpers |
| `foreground_templates` | First non-empty result sets the foreground color |

## CLI quick reference

| Command | Purpose |
|---------|---------|
| `oh-my-posh init <shell> --config cfg` | Print the shell init script |
| `oh-my-posh debug` | Render the prompt with timings |
| `oh-my-posh config migrate` | Upgrade config to the newest format |
| `oh-my-posh config export --format json` | Convert theme format |
| `oh-my-posh get shell` | Print detected shell |
