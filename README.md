# dotfiles

Cross-platform dotfiles managed with Python.

## Requirements

- Python 3.14+
- [uv](https://github.com/astral-sh/uv)

## Setup

```sh
uv sync
```

## Usage

```sh
# List available modules
uv run dotfiles list

# List modules with descriptions
uv run dotfiles list --verbose

# Install all modules
uv run dotfiles install

# Install a specific module
uv run dotfiles install git

# Dry run (no filesystem modifications)
uv run dotfiles install --dry-run
uv run dotfiles install git --dry-run
```

## Modules

| Module     | Description |
|------------|-------------|
| `bash`     | Sources `bashrc.bash` into `~/.bashrc` (Linux/macOS only) |
| `git`      | Injects `[include]` paths into `~/.gitconfig` for all `*.gitconfig*` files |
| `powershell` | Symlinks PS profiles and utilities to the appropriate profile directory |
