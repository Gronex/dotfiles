from modules.module_config import ModuleConfig, list_modules


def test_name_from_path(tmp_path):
    config = ModuleConfig(path=tmp_path / "bash")
    assert config.name == "bash"


def test_description_loaded_from_readme(tmp_path):
    module = tmp_path / "bash"
    module.mkdir()
    (module / "readme.md").write_text("Some description")
    config = ModuleConfig(path=module)
    assert config.description == "Some description"


def test_description_none_when_no_readme(tmp_path):
    module = tmp_path / "bash"
    module.mkdir()
    config = ModuleConfig(path=module)
    assert config.description is None


def test_description_from_module_json_overrides_readme(tmp_path):
    module = tmp_path / "bash"
    module.mkdir()
    (module / "readme.md").write_text("From readme")
    (module / ".dotfiles.module.json").write_text('{"description": "From json"}')
    config = ModuleConfig(path=module)
    assert config.description == "From json"


def test_description_is_first_paragraph_of_readme(tmp_path):
    module = tmp_path / "bash"
    module.mkdir()
    (module / "readme.md").write_text("Short description.\n\nLong reference body.")
    config = ModuleConfig(path=module)
    assert config.description == "Short description."


def test_list_modules_returns_all_subdirs(tmp_path):
    for name in ["bash", "git", "powershell"]:
        (tmp_path / name).mkdir()
    modules = list_modules(root=tmp_path)
    assert {m.name for m in modules} == {"bash", "git", "powershell"}


def test_list_modules_returns_correct_types(tmp_path):
    (tmp_path / "bash").mkdir()
    modules = list_modules(root=tmp_path)
    assert all(isinstance(m, ModuleConfig) for m in modules)


def test_list_modules_paths_are_absolute(tmp_path):
    (tmp_path / "bash").mkdir()
    modules = list_modules(root=tmp_path)
    assert all(m.path.is_absolute() for m in modules)
