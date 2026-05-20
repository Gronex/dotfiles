from pathlib import Path
from typing import override

from modules.base_installer import OS, BaseInstaller


class BashInstaller(BaseInstaller):
    @override
    def install(self):
        if OS.is_windows():
            print(f"[SKIP] '{self.module_config.name}' module not supported on windows")
            return

        target = Path("~/.bashrc").expanduser()
        source = self.module_config.path / "bashrc.bash"

        self._install_source_link(source=source, target=target)
