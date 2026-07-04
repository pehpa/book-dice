"""Configuration data model, loading, and persistence for book-dice."""

from __future__ import annotations

import json
from pathlib import Path

from pydantic import BaseModel, Field, ValidationError

DEFAULT_CONFIG_PATH = Path("config.json")


class Settings(BaseModel):
    default_dice_faces: int = 6
    web_port: int = 5000


class Category(BaseModel):
    weight: float = Field(ge=0)
    segments: int = Field(ge=1)


class Config(BaseModel):
    settings: Settings = Field(default_factory=Settings)
    categories: dict[str, Category] = Field(default_factory=dict)


DEFAULT_CONFIG = Config(
    settings=Settings(default_dice_faces=6, web_port=5000),
    categories={
        "Science Fiction": Category(weight=50, segments=4),
        "Belletristik": Category(weight=20, segments=6),
        "Sachbücher": Category(weight=30, segments=3),
    },
)


class ConfigError(Exception):
    """Raised when config.json is missing, malformed, or fails validation."""


def load_config(path: Path = DEFAULT_CONFIG_PATH) -> Config:
    if not path.exists():
        save_config(path, DEFAULT_CONFIG)
        return DEFAULT_CONFIG.model_copy(deep=True)

    try:
        raw = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        raise ConfigError(f"{path} is not valid JSON: {exc}") from exc

    try:
        return Config.model_validate(raw)
    except ValidationError as exc:
        raise ConfigError(
            f"{path} does not match the expected config schema: {exc}"
        ) from exc


def save_config(path: Path, config: Config) -> None:
    tmp_path = path.with_suffix(path.suffix + ".tmp")
    tmp_path.write_text(
        json.dumps(config.model_dump(), indent=2, ensure_ascii=False) + "\n"
    )
    tmp_path.replace(path)
