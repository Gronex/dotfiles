from modules.base_installer import BaseInstaller
from modules.bash import BashInstaller
from modules.git import GitInstaller
from modules.module_config import ModuleConfig


def install_module(module_config: ModuleConfig, *args, **kwargs):
    installer = get_installer(module_config, *args, **kwargs)
    if not installer:
        raise NotImplementedError(f"No installer exists for '{module_config.name}'")
    installer.install()


def get_installer(module_config: ModuleConfig, *args, **kwargs) -> BaseInstaller | None:
    match module_config.name:
        case "bash":
            return BashInstaller(module_config, *args, **kwargs)
        case "git":
            return GitInstaller(module_config, *args, **kwargs)
        case "PowerShell":
            return None
        case _:
            return None
