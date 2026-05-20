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

    def _install_source_link(
        self, *, source: Path, target: Path, marker: str = "# dotfiles-managed"
    ):
        if not source.exists():
            raise FileNotFoundError(source)

        target = target.resolve()
        source_line = f"source {source.resolve()}"

        lines = []
        if target.exists():
            lines = target.read_text().splitlines()
            marker_index = next(
                (i for i, line in enumerate(lines) if line == marker), None
            )

            if marker_index is not None:
                source_index = marker_index + 1
                if source_index < len(lines) and lines[source_index] == source_line:
                    print(f"[SKIP] {target} already sources {source}")
                    return
                if source_index >= len(lines):
                    lines.append(source_line)
                else:
                    lines[source_index] = source_line

                print(f"[{self.get_edit('UPD')}] {target} -> {source_line}")
                if self.dry_run:
                    return

                with target.open("w") as f:
                    f.write("\n".join(lines) + "\n")
                return

        print(f"[{self.get_edit('SRC')}] {target} <- {source_line}")
        if self.dry_run:
            return

        with target.open(mode="a") as f:
            f.writelines(f"\n{marker}\n{source_line}\n")
