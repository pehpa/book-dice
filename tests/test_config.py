import json
from pathlib import Path

import pytest
from pydantic import ValidationError

from book_dice.config import (
    DEFAULT_CONFIG,
    Config,
    ConfigError,
    Settings,
    load_config,
    save_config,
)


def test_settings_rejects_default_dice_faces_below_one() -> None:
    with pytest.raises(ValidationError):
        Settings(default_dice_faces=0)


def test_load_config_creates_default_when_missing(tmp_path: Path) -> None:
    config_path = tmp_path / "config.json"
    assert not config_path.exists()

    config = load_config(config_path)

    assert config_path.exists()
    assert config == DEFAULT_CONFIG
    on_disk = Config.model_validate(json.loads(config_path.read_text()))
    assert on_disk == DEFAULT_CONFIG


def test_load_config_does_not_mutate_shared_default(tmp_path: Path) -> None:
    config_path = tmp_path / "config.json"
    config = load_config(config_path)

    config.categories["New"] = config.categories["Science Fiction"]

    assert "New" not in DEFAULT_CONFIG.categories


def test_load_config_round_trips_existing_file(tmp_path: Path) -> None:
    config_path = tmp_path / "config.json"
    original = Config.model_validate(
        {
            "settings": {"default_dice_faces": 8, "web_port": 9000},
            "categories": {"Test": {"weight": 10, "segments": 2}},
        }
    )
    save_config(config_path, original)

    loaded = load_config(config_path)

    assert loaded == original


def test_load_config_raises_on_malformed_json(tmp_path: Path) -> None:
    config_path = tmp_path / "config.json"
    config_path.write_text("{not valid json")

    with pytest.raises(ConfigError):
        load_config(config_path)


def test_load_config_raises_on_schema_mismatch(tmp_path: Path) -> None:
    config_path = tmp_path / "config.json"
    config_path.write_text(
        json.dumps({"settings": {}, "categories": {"Bad": {"weight": "x"}}})
    )

    with pytest.raises(ConfigError):
        load_config(config_path)


def test_save_config_is_atomic_and_leaves_no_tmp_file(tmp_path: Path) -> None:
    config_path = tmp_path / "config.json"
    save_config(config_path, DEFAULT_CONFIG)

    assert config_path.exists()
    assert not config_path.with_suffix(".json.tmp").exists()
    assert list(tmp_path.iterdir()) == [config_path]
