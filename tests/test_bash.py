import pytest
from unittest.mock import patch
from modules.bash import BashInstaller
from modules.module_config import ModuleConfig


@pytest.fixture
def module_path(tmp_path):
    module = tmp_path / "bash"
    module.mkdir()
    (module / "bashrc.bash").touch()
    return module


@pytest.fixture
def installer(module_path):
    return BashInstaller(module_config=ModuleConfig(path=module_path), dry_run=False)


# --- _install_source_link ---

def test_raises_when_source_missing(tmp_path):
    module = tmp_path / "bash"
    module.mkdir()
    installer = BashInstaller(module_config=ModuleConfig(path=module), dry_run=False)
    with pytest.raises(FileNotFoundError):
        installer._install_source_link(
            source=module / "bashrc.bash",
            target=tmp_path / ".bashrc",
        )


def test_new_target_created_with_marker_and_source(installer, tmp_path):
    source = installer.module_config.path / "bashrc.bash"
    target = tmp_path / ".bashrc"
    installer._install_source_link(source=source, target=target)
    content = target.read_text()
    assert "# dotfiles-managed" in content
    assert f"source {source.resolve()}" in content


def test_existing_target_no_marker_appends(installer, tmp_path):
    source = installer.module_config.path / "bashrc.bash"
    target = tmp_path / ".bashrc"
    target.write_text("export FOO=bar\n")
    installer._install_source_link(source=source, target=target)
    content = target.read_text()
    assert "export FOO=bar" in content
    assert "# dotfiles-managed" in content
    assert f"source {source.resolve()}" in content


def test_existing_marker_different_source_updates_line(installer, tmp_path):
    source = installer.module_config.path / "bashrc.bash"
    target = tmp_path / ".bashrc"
    target.write_text("# dotfiles-managed\nsource /old/path\n")
    installer._install_source_link(source=source, target=target)
    content = target.read_text()
    assert "source /old/path" not in content
    assert f"source {source.resolve()}" in content
    assert content.count("# dotfiles-managed") == 1


def test_existing_marker_same_source_skips(installer, tmp_path, capsys):
    source = installer.module_config.path / "bashrc.bash"
    target = tmp_path / ".bashrc"
    source_line = f"source {source.resolve()}"
    original = f"# dotfiles-managed\n{source_line}\n"
    target.write_text(original)
    installer._install_source_link(source=source, target=target)
    assert capsys.readouterr().out.startswith("[SKIP]")
    assert target.read_text() == original


def test_dry_run_does_not_write_file(module_path, tmp_path):
    installer = BashInstaller(module_config=ModuleConfig(path=module_path), dry_run=True)
    source = module_path / "bashrc.bash"
    target = tmp_path / ".bashrc"
    installer._install_source_link(source=source, target=target)
    assert not target.exists()


# --- install() ---

def test_windows_is_skipped(module_path, tmp_path):
    installer = BashInstaller(module_config=ModuleConfig(path=module_path), dry_run=False)
    with patch("modules.bash.OS.is_windows", return_value=True):
        installer.install()
    assert not (tmp_path / ".bashrc").exists()


def test_install_writes_to_home_bashrc(module_path, tmp_path):
    installer = BashInstaller(module_config=ModuleConfig(path=module_path), dry_run=False)
    with patch("modules.bash.OS.is_windows", return_value=False):
        installer.install()
    content = (tmp_path / ".bashrc").read_text()
    assert "# dotfiles-managed" in content
