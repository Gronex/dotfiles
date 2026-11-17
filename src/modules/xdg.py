import os
from pathlib import Path


def config_home() -> Path:
    """XDG config root: ``$XDG_CONFIG_HOME`` when non-empty, otherwise ~/.config."""
    if config_home := os.getenv("XDG_CONFIG_HOME"):
        return Path(config_home)
    return Path("~/.config").expanduser()


def config_dir(name: str) -> Path:
    """XDG config directory for a tool, e.g. ``config_dir('nvim')`` -> ~/.config/nvim."""
    return config_home() / name
