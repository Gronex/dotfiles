import pytest
from modules.git import GitInstaller
from modules.module_config import ModuleConfig


@pytest.fixture
def installer(tmp_path):
    return GitInstaller(module_config=ModuleConfig(path=tmp_path), dry_run=True)


def test_empty_file(installer):
    result = installer.calculate_lines([])
    assert "[include]\n" in result
    assert "# dotfiles start\n" in result
    assert "# dotfiles end\n" in result
    start = result.index("# dotfiles start\n")
    end = result.index("# dotfiles end\n")
    assert start < end


def test_existing_markers_replaced(installer):
    lines = [
        "[user]\n",
        "\tname = Test\n",
        "[include]\n",
        "# dotfiles start\n",
        "\tpath = /old/path\n",
        "# dotfiles end\n",
    ]
    result = installer.calculate_lines(lines)
    assert "\tpath = /old/path\n" not in result
    assert "# dotfiles start\n" in result
    assert "# dotfiles end\n" in result
    assert "[user]\n" in result
    assert result.count("[include]\n") == 1


def test_include_present_no_markers(installer):
    lines = [
        "[user]\n",
        "\tname = Test\n",
        "[include]\n",
        "\tpath = /some/manual/config\n",
    ]
    result = installer.calculate_lines(lines)
    assert "# dotfiles start\n" in result
    assert "# dotfiles end\n" in result
    assert "[user]\n" in result
    assert result.count("[include]\n") == 1


def test_line_order_preserved(installer):
    lines = [
        "[user]\n",
        "\tname = Test\n",
        "[include]\n",
        "# dotfiles start\n",
        "\tpath = /old/path\n",
        "# dotfiles end\n",
        "[core]\n",
        "\teditor = vim\n",
    ]
    result = installer.calculate_lines(lines)
    user_idx = result.index("[user]\n")
    include_idx = result.index("[include]\n")
    start_idx = result.index("# dotfiles start\n")
    end_idx = result.index("# dotfiles end\n")
    core_idx = result.index("[core]\n")
    assert user_idx < include_idx < start_idx < end_idx < core_idx


def test_no_include_section(installer):
    lines = [
        "[user]\n",
        "\tname = Test\n",
        "[core]\n",
        "\teditor = vim\n",
    ]
    result = installer.calculate_lines(lines)
    assert "[include]\n" in result
    assert "# dotfiles start\n" in result
    assert "# dotfiles end\n" in result
    assert "[user]\n" in result
    assert "[core]\n" in result
