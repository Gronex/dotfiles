import re
from pathlib import Path
from typing import override

from modules.base_installer import BaseInstaller


class GitInstaller(BaseInstaller):
    @override
    def install(self):
        target = Path("~/.gitconfig").expanduser()

        if target.exists():
            with target.open("r") as f:
                lines = f.readlines()
        else:
            lines = []
        lines = self.calculate_lines(lines)

        self.write_lines(target, lines)

    def calculate_lines(self, lines: list[str]):
        configs = sorted(self.module_config.path.glob("*.gitconfig*"))
        include_lines = [f"\tpath = {config}\n" for config in configs]

        start_marker = "# dotfiles start"
        end_marker = "# dotfiles end"
        no_marker = False

        marker_start_index = self.find_line_index(lines, start_marker)
        marker_end_index = self.find_line_index(lines, end_marker)

        if marker_start_index is None:
            print("Marker not found, looking for [include]")
            marker_start_index = self.find_line_index(lines, r"\s*\[include\]")
            no_marker = True
        if marker_start_index is None:
            print("[include] not found, creating from scratch")
            marker_start_index = len(lines)
            lines.append("[include]\n")

        if no_marker:
            marker_start_index = marker_start_index + 1

        marker_end_index = (
            marker_end_index if marker_end_index is not None else marker_start_index
        )

        if not no_marker:
            del lines[marker_start_index : marker_end_index + 1]

        lines[marker_start_index:marker_start_index] = [
            start_marker + "\n",
            *include_lines,
            end_marker + "\n",
        ]
        return lines

    def write_lines(self, target: Path, lines: list[str]):
        if self.dry_run:
            print("[DRY_RUN] Would have written file:")
            print()
            for line in lines:
                print(line, end="")
        else:
            with target.open("w") as f:
                f.writelines(lines)

    def find_line_index(
        self, lines: list[str], match: re.Pattern[str] | str
    ) -> int | None:
        return next((i for i, line in enumerate(lines) if re.match(match, line)), None)
