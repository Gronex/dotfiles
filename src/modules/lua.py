from dataclasses import dataclass
from pathlib import Path
from typing import override

from modules.base_installer import BaseInstaller


@dataclass
class LuaInstaller(BaseInstaller):
    """Appends ``dofile`` links to a Lua config file.

    target: config file to append the links to (e.g. ~/.config/nvim/init.lua)
    files: names of the Lua files in the module directory to link
    """

    target: Path
    files: list[str]

    @override
    def install(self):
        sources = [self.module_config.path / file for file in self.files]
        missing = [str(source) for source in sources if not source.exists()]
        if missing:
            raise FileNotFoundError(missing)

        include_lines = [
            f"dofile('{source.resolve().as_posix()}')" for source in sources
        ]

        lines = self.target.read_text().splitlines() if self.target.exists() else []
        new_lines = [line for line in include_lines if line not in lines]

        if not new_lines:
            print(f"[SKIP] {self.target} already loads all module files")
            return

        lines.extend(new_lines)
        for line in new_lines:
            print(f"[{self.get_edit('APP')}] {self.target} <- {line}")

        self.ensure_path(self.target.parent)
        self.write_lines(self.target, [f"{line}\n" for line in lines])
