from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class ModuleConfig:
    path: Path
    description: str | None = field(init=False)

    @property
    def name(self):
        return self.path.name

    def __post_init__(self):
        description_path = self.path / "readme.md"
        self.description = (
            description_path.read_text() if description_path.exists() else None
        )


def list_modules(root: Path | None = None) -> list[ModuleConfig]:
    if not root:
        root = get_module_root()
    return [ModuleConfig(path=path.resolve()) for path in root.iterdir()]


def get_module_root() -> Path:
    root = Path(__file__).resolve().parent
    return Path(root / "../../modules").resolve()
