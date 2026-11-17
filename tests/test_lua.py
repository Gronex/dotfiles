import pytest
from modules.lua import LuaInstaller
from modules.module_config import ModuleConfig

# HOME is patched to tmp_path by the autouse patch_home fixture, so paths
# under ~ resolve inside the test's tmp_path.


@pytest.fixture
def module_path(tmp_path):
    module = tmp_path / "nvim"
    module.mkdir()
    (module / "init.lua").write_text("-- init\n")
    return module


@pytest.fixture
def target(tmp_path):
    return tmp_path / ".config" / "nvim" / "init.lua"


def make_installer(module_path, target, dry_run=False, files=("init.lua",)):
    return LuaInstaller(
        module_config=ModuleConfig(path=module_path),
        dry_run=dry_run,
        target=target,
        files=list(files),
    )


def include_line(module_path, name):
    return f"dofile('{(module_path / name).resolve().as_posix()}')"


def test_creates_target_with_dofile(module_path, target):
    make_installer(module_path, target).install()
    assert target.read_text() == include_line(module_path, "init.lua") + "\n"


def test_links_multiple_files(module_path, target):
    (module_path / "keymaps.lua").write_text("-- keymaps\n")
    make_installer(module_path, target, files=["init.lua", "keymaps.lua"]).install()
    content = target.read_text()
    assert content == (
        include_line(module_path, "init.lua") + "\n"
        + include_line(module_path, "keymaps.lua") + "\n"
    )


def test_appends_only_missing_files(module_path, target):
    (module_path / "keymaps.lua").write_text("-- keymaps\n")
    target.parent.mkdir(parents=True)
    target.write_text(include_line(module_path, "init.lua") + "\n")
    make_installer(module_path, target, files=["init.lua", "keymaps.lua"]).install()
    content = target.read_text()
    assert content.count(include_line(module_path, "init.lua")) == 1
    assert content.count(include_line(module_path, "keymaps.lua")) == 1


def test_appends_to_existing_file(module_path, target):
    target.parent.mkdir(parents=True)
    target.write_text("local existing = true")  # no trailing newline
    make_installer(module_path, target).install()
    assert target.read_text() == (
        "local existing = true\n" + include_line(module_path, "init.lua") + "\n"
    )


def test_skips_when_all_files_present(module_path, target, capsys):
    installer = make_installer(module_path, target)
    installer.install()
    original = target.read_text()

    installer.install()

    assert "[SKIP]" in capsys.readouterr().out
    assert target.read_text() == original


def test_dry_run_does_not_write(module_path, target):
    make_installer(module_path, target, dry_run=True).install()
    assert not target.exists()
    assert not target.parent.exists()


def test_missing_source_raises(module_path, target):
    (module_path / "init.lua").unlink()
    with pytest.raises(FileNotFoundError) as excinfo:
        make_installer(module_path, target).install()
    assert "init.lua" in str(excinfo.value)
