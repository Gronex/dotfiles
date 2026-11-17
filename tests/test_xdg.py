from modules.xdg import config_dir, config_home


def test_config_home_defaults_to_home_config(tmp_path):
    assert config_home() == tmp_path / ".config"


def test_config_home_respects_env(tmp_path, monkeypatch):
    custom = tmp_path / "custom-xdg"
    monkeypatch.setenv("XDG_CONFIG_HOME", str(custom))
    assert config_home() == custom


def test_config_home_ignores_empty_env(tmp_path, monkeypatch):
    monkeypatch.setenv("XDG_CONFIG_HOME", "")
    assert config_home() == tmp_path / ".config"


def test_config_dir_appends_name(tmp_path, monkeypatch):
    monkeypatch.setenv("XDG_CONFIG_HOME", str(tmp_path / "xdg"))
    assert config_dir("wezterm") == tmp_path / "xdg" / "wezterm"
