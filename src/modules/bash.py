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
