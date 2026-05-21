import pytest


@pytest.fixture(autouse=True)
def patch_home(tmp_path, monkeypatch):
    monkeypatch.setenv("HOME", str(tmp_path))
