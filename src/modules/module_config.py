from dataclasses import dataclass, field
import json
from pathlib import Path

@dataclass
class ConfigFile:
    enabled: bool = field(default=True)
    description: str | None = field(default=None)

@dataclass
class ModuleConfig:
    path: Path
    description: str | None = field(init=False)
    enabled: bool = field(init=False, default=True)

    @property
    def name(self):
        return self.path.name

    def __post_init__(self):
        self._load_config()

    def _load_config(self):
        config_path = self.path / ".dotfiles.module.json"
        if not config_path.exists():
            return
        with config_path.open("r") as f:
            config = json.load(f, object_hook=lambda d: ConfigFile(**d))
        self.enabled = config.enabled
        self.description = config.description


def list_modules(root: Path | None = None) -> list[ModuleConfig]:
    if not root:
        root = get_module_root()
    modules = [ModuleConfig(path=path.resolve()) for path in root.iterdir()]
    return [module for module in modules if module.enabled]


def get_module_root() -> Path:
    root = Path(__file__).resolve().parent
    return Path(root / "../../modules").resolve()
