import pytest
from unittest.mock import MagicMock, patch
from modules.bash import BashInstaller
from modules.git import GitInstaller
from modules.install import MissingInstallerError, get_installer, install_module
from modules.lua import LuaInstaller
from modules.module_config import ModuleConfig
from modules.powershell import PowerShellInstaller


def make_config(tmp_path, name):
    path = tmp_path / name
    path.mkdir()
    return ModuleConfig(path=path)


def test_get_installer_bash(tmp_path):
    assert isinstance(get_installer(make_config(tmp_path, "bash"), dry_run=True), BashInstaller)


def test_get_installer_git(tmp_path):
    assert isinstance(get_installer(make_config(tmp_path, "git"), dry_run=True), GitInstaller)


def test_get_installer_powershell(tmp_path):
    assert isinstance(get_installer(make_config(tmp_path, "powershell"), dry_run=True), PowerShellInstaller)


def test_get_installer_nvim(tmp_path):
    assert isinstance(get_installer(make_config(tmp_path, "nvim"), dry_run=True), LuaInstaller)


def test_get_installer_wezterm(tmp_path):
    assert isinstance(get_installer(make_config(tmp_path, "wezterm"), dry_run=True), LuaInstaller)


def test_get_installer_nvim_targets_xdg_config(tmp_path, monkeypatch):
    xdg_root = tmp_path / "xdg"
    monkeypatch.setenv("XDG_CONFIG_HOME", str(xdg_root))
    installer = get_installer(make_config(tmp_path, "nvim"), dry_run=True)
    assert installer.target == xdg_root / "nvim" / "init.lua"
    assert installer.files == ["init.lua"]


def test_get_installer_wezterm_targets_xdg_config(tmp_path, monkeypatch):
    xdg_root = tmp_path / "xdg"
    monkeypatch.setenv("XDG_CONFIG_HOME", str(xdg_root))
    installer = get_installer(make_config(tmp_path, "wezterm"), dry_run=True)
    assert installer.target == xdg_root / "wezterm" / "wezterm.lua"
    assert installer.files == ["wezterm.lua"]


def test_get_installer_case_insensitive(tmp_path):
    assert isinstance(get_installer(make_config(tmp_path, "Bash"), dry_run=True), BashInstaller)
    assert isinstance(get_installer(make_config(tmp_path, "GIT"), dry_run=True), GitInstaller)
    assert isinstance(get_installer(make_config(tmp_path, "PowerShell"), dry_run=True), PowerShellInstaller)


def test_get_installer_unknown_returns_none(tmp_path):
    assert get_installer(make_config(tmp_path, "unknown"), dry_run=True) is None


def test_install_module_raises_for_unknown(tmp_path):
    with pytest.raises(MissingInstallerError):
        install_module(make_config(tmp_path, "unknown"), dry_run=True)


def test_missing_installer_error_carries_module_config(tmp_path):
    config = make_config(tmp_path, "unknown")
    try:
        install_module(config, dry_run=True)
    except MissingInstallerError as e:
        assert e.module_config is config
        assert "unknown" in e.message
    else:
        pytest.fail("MissingInstallerError not raised")


def test_install_module_calls_install(tmp_path):
    config = make_config(tmp_path, "bash")
    mock_installer = MagicMock()
    with patch("modules.install.get_installer", return_value=mock_installer):
        install_module(config, dry_run=True)
    mock_installer.install.assert_called_once()
