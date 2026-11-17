from modules.base_installer import BaseInstaller
from modules.bash import BashInstaller
from modules.git import GitInstaller
from modules.lua import LuaInstaller
from modules.module_config import ModuleConfig
from modules.powershell import PowerShellInstaller
from modules.xdg import config_dir


class MissingInstallerError(Exception):
    """Raised when no matching module installer exists."""

    def __init__(self, message: str, module_config: ModuleConfig) -> None:
        super().__init__(message)
        self.message = message
        self.module_config = module_config


def install_module(module_config: ModuleConfig, *args, **kwargs):
    installer = get_installer(module_config, *args, **kwargs)
    if installer:
        installer.install()
    else:
        raise MissingInstallerError(
            f"No installer implemented for '{module_config.name}'", module_config
        )


def get_installer(module_config: ModuleConfig, *args, **kwargs) -> BaseInstaller | None:
    match module_config.name.lower():
        case "bash":
            return BashInstaller(module_config, *args, **kwargs)
        case "git":
            return GitInstaller(module_config, *args, **kwargs)
        case "powershell":
            return PowerShellInstaller(module_config, *args, **kwargs)
        case "nvim":
            return LuaInstaller(
                module_config,
                *args,
                target=config_dir("nvim") / "init.lua",
                files=["init.lua"],
                **kwargs,
            )
        case "wezterm":
            return LuaInstaller(
                module_config,
                *args,
                target=config_dir("wezterm") / "wezterm.lua",
                files=["wezterm.lua"],
                **kwargs,
            )
        case _:
            return None
