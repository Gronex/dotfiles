import pytest
from unittest.mock import patch
from modules.module_config import ModuleConfig
from modules.powershell import PowerShellInstaller


@pytest.fixture
def module_path(tmp_path):
    module = tmp_path / "PowerShell"
    module.mkdir()
    for f in [
        "Core.Powershell_profile.ps1",
        "Windows.Powershell_profile.ps1",
        "Shared.Powershell_profile.ps1",
        "Aliases.ps1",
        "Utility.psm1",
    ]:
        (module / f).touch()
    return module


@pytest.fixture
def installer(module_path):
    return PowerShellInstaller(module_config=ModuleConfig(path=module_path), dry_run=False)


# --- core_root_path ---

def test_core_root_path_linux(installer, tmp_path):
    with patch("modules.powershell.OS.is_windows", return_value=False):
        assert installer.core_root_path == tmp_path / ".config" / "powershell"


def test_core_root_path_windows(installer, tmp_path):
    with patch("modules.powershell.OS.is_windows", return_value=True):
        assert installer.core_root_path == tmp_path / "Documents" / "PowerShell"


# --- ensure_path ---

def test_ensure_path_creates_nested_directory(installer, tmp_path):
    new_dir = tmp_path / "a" / "b" / "c"
    installer.ensure_path(new_dir)
    assert new_dir.exists()


def test_ensure_path_dry_run_no_create(module_path, tmp_path):
    installer = PowerShellInstaller(module_config=ModuleConfig(path=module_path), dry_run=True)
    new_dir = tmp_path / "a" / "b" / "c"
    installer.ensure_path(new_dir)
    assert not new_dir.exists()


def test_ensure_path_existing_does_not_raise(installer, tmp_path):
    installer.ensure_path(tmp_path)


# --- symlink ---

def test_symlink_creates_link_with_correct_target(installer, module_path, tmp_path):
    link_dir = tmp_path / "links"
    link_dir.mkdir()
    installer.symlink(link_dir, module_path, "Aliases.ps1")
    link = link_dir / "Aliases.ps1"
    assert link.is_symlink()
    assert link.readlink() == module_path / "Aliases.ps1"


def test_symlink_with_rename(installer, module_path, tmp_path):
    link_dir = tmp_path / "links"
    link_dir.mkdir()
    installer.symlink(
        link_dir, module_path, "Microsoft.PowerShell_profile.ps1", "Core.Powershell_profile.ps1"
    )
    link = link_dir / "Microsoft.PowerShell_profile.ps1"
    assert link.is_symlink()
    assert link.readlink() == module_path / "Core.Powershell_profile.ps1"


def test_symlink_dry_run_no_link_created(module_path, tmp_path):
    installer = PowerShellInstaller(module_config=ModuleConfig(path=module_path), dry_run=True)
    link_dir = tmp_path / "links"
    link_dir.mkdir()
    installer.symlink(link_dir, module_path, "Aliases.ps1")
    assert not (link_dir / "Aliases.ps1").exists()


def test_symlink_existing_overrides_when_confirmed(installer, module_path, tmp_path):
    link_dir = tmp_path / "links"
    link_dir.mkdir()
    old_target = tmp_path / "old.ps1"
    old_target.touch()
    (link_dir / "Aliases.ps1").symlink_to(old_target)
    with patch.object(installer, "confirm", return_value=True):
        installer.symlink(link_dir, module_path, "Aliases.ps1")
    assert (link_dir / "Aliases.ps1").readlink() == module_path / "Aliases.ps1"


def test_symlink_existing_skips_when_declined(installer, module_path, tmp_path):
    link_dir = tmp_path / "links"
    link_dir.mkdir()
    old_target = tmp_path / "old.ps1"
    old_target.touch()
    (link_dir / "Aliases.ps1").symlink_to(old_target)
    with patch.object(installer, "confirm", return_value=False):
        installer.symlink(link_dir, module_path, "Aliases.ps1")
    assert (link_dir / "Aliases.ps1").readlink() == old_target


# --- install / install_legacy ---

def test_install_creates_all_symlinks_on_linux(module_path, tmp_path):
    installer = PowerShellInstaller(module_config=ModuleConfig(path=module_path), dry_run=False)
    with patch("modules.powershell.OS.is_windows", return_value=False):
        installer.install()
    config_root = tmp_path / ".config" / "powershell"
    assert (config_root / "Microsoft.PowerShell_profile.ps1").is_symlink()
    for f in ["Shared.Powershell_profile.ps1", "Aliases.ps1", "Utility.psm1"]:
        assert (config_root / f).is_symlink()


def test_install_legacy_skipped_on_linux(module_path, tmp_path):
    installer = PowerShellInstaller(module_config=ModuleConfig(path=module_path), dry_run=False)
    with patch("modules.powershell.OS.is_windows", return_value=False):
        installer.install_legacy()
    assert not (tmp_path / "Documents" / "WindowsPowerShell").exists()


def test_install_legacy_creates_symlinks_on_windows(module_path, tmp_path):
    installer = PowerShellInstaller(module_config=ModuleConfig(path=module_path), dry_run=False)
    with patch("modules.powershell.OS.is_windows", return_value=True):
        installer.install()
    legacy_root = tmp_path / "Documents" / "WindowsPowerShell"
    assert (legacy_root / "Microsoft.PowerShell_profile.ps1").is_symlink()
    for f in ["Shared.Powershell_profile.ps1", "Aliases.ps1", "Utility.psm1"]:
        assert (legacy_root / f).is_symlink()
