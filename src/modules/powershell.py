from pathlib import Path
from typing import override

from modules.base_installer import OS, BaseInstaller


class PowerShellInstaller(BaseInstaller):
    @property
    def utility_files(self):
        return [
            "Shared.Powershell_profile.ps1",
            "Aliases.ps1",
            "Utility.psm1",
        ]

    @property
    def core_root_path(self):
        return (
            Path("~/Documents/PowerShell").expanduser()
            if OS.is_windows()
            else Path("~/.config/powershell").expanduser()
        )

    @override
    def install(self):
        self.ensure_path(self.core_root_path)

        self.symlink(
            self.core_root_path,
            self.module_config.path,
            "Microsoft.PowerShell_profile.ps1",
            "Core.Powershell_profile.ps1",
        )

        for file_name in self.utility_files:
            self.symlink(self.core_root_path, self.module_config.path, file_name)

        self.install_legacy()

    def install_legacy(self):
        if not OS.is_windows():
            return

        root_path = Path("~/Documents/WindowsPowerShell").expanduser()
        self.symlink(
            root_path,
            self.module_config.path,
            "Microsoft.PowerShell_profile.ps1",
            "Windows.Powershell_profile.ps1",
        )

        for file_name in self.utility_files:
            self.symlink(root_path, self.module_config.path, file_name)

    def symlink(
        self,
        source_dir: Path,
        target_dir: Path,
        file_name: str,
        origin_name: str | None = None,
    ):
        self.ensure_path(source_dir)
        origin_name = origin_name if origin_name else file_name
        source_file = source_dir / file_name
        target_file = target_dir / origin_name
        prefix = "[DRY_RUN] " if self.dry_run else ""

        if source_file.is_symlink():
            print(f"existing symlink found {source_file} -> {source_file.readlink()}")
            override = self.confirm(f"Override existing file '{source_file}'?")
            if not override:
                return
            print(f"{prefix}overriding existing link from {source_file}")
            if not self.dry_run:
                source_file.unlink(missing_ok=True)

        print(f"{prefix}linking: {source_file} -> {target_file}")
        if not self.dry_run:
            source_file.symlink_to(target_file)

    def ensure_path(self, path: Path):
        if not path.exists():
            print(f"Creating path {path}")
            if self.dry_run:
                print(f"[DRY_RUN]: {path}")
            else:
                path.mkdir(parents=True, exist_ok=True)
