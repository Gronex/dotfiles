import platform
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
from pathlib import Path

from modules.module_config import ModuleConfig


class OS(Enum):
    LINUX = "linux"
    MACOS = "macos"
    WINDOWS = "windows"

    @classmethod
    def current(cls) -> "OS":
        match platform.system():
            case "Linux":
                return cls.LINUX
            case "Darwin":
                return cls.MACOS
            case "Windows":
                return cls.WINDOWS
            case other:
                raise ValueError(f"Unsupported OS: {other}")

    @classmethod
    def is_windows(cls) -> bool:
        return cls.WINDOWS == cls.current()

    @classmethod
    def is_linux(cls) -> bool:
        return cls.LINUX == cls.current()

    @classmethod
    def is_mac_os(cls) -> bool:
        return cls.MACOS == cls.current()


@dataclass
class BaseInstaller(ABC):
    module_config: ModuleConfig
    dry_run: bool

    @abstractmethod
    def install(self):
        pass

    def get_edit(self, tag: str):
        return f"DRY_RUN - {tag}" if self.dry_run else tag

    def confirm(self, message: str):
        if self.dry_run:
            return True
        answer = input(f"{message} [(y)/N]: ").lower()
        return answer in ("", "y")

    def ensure_path(self, path: Path):
        if path.exists():
            return
        print(f"Creating path {path}")
        if self.dry_run:
            print(f"[DRY_RUN]: {path}")
        else:
            path.mkdir(parents=True, exist_ok=True)

    def write_lines(self, target: Path, lines: list[str]):
        """Write newline-terminated ``lines`` to ``target``."""
        if self.dry_run:
            print("[DRY_RUN] Would have written file:")
            print()
            for line in lines:
                print(line, end="")
        else:
            with target.open("w") as f:
                f.writelines(lines)
