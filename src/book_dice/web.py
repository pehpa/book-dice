"""FastAPI web UI for book-dice."""

from __future__ import annotations

import random
from pathlib import Path

import uvicorn
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import FileResponse
from pydantic import BaseModel

from book_dice.config import Config, load_config, save_config
from book_dice.core import format_die, roll_die, select_shelf

STATIC_DIR = Path(__file__).parent / "static"


class ShelfSelectionResponse(BaseModel):
    category: str
    weight_percent: float
    segment: int
    segments_total: int
    dice_faces: int
    instruction: str


class DieRollResponse(BaseModel):
    die_roll: int
    die_faces: int
    die_glyph: str


def create_app(config_path: Path) -> FastAPI:
    app = FastAPI(title="book-dice")

    @app.get("/")
    def index() -> FileResponse:
        return FileResponse(STATIC_DIR / "index.html")

    @app.get("/api/config")
    def get_config() -> Config:
        return load_config(config_path)

    @app.post("/api/config")
    def post_config(config: Config) -> Config:
        total_weight = sum(c.weight for c in config.categories.values())
        if config.categories and abs(total_weight - 100) > 1e-6:
            detail = f"Category weights must sum to 100 (currently {total_weight:g})."
            raise HTTPException(status_code=400, detail=detail)

        save_config(config_path, config)
        return config

    @app.post("/api/select-shelf")
    def select_shelf_endpoint() -> ShelfSelectionResponse:
        config = load_config(config_path)
        try:
            shelf = select_shelf(config)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc

        dice_faces = config.settings.default_dice_faces
        return ShelfSelectionResponse(
            category=shelf.category_name,
            weight_percent=shelf.weight_percent,
            segment=shelf.segment,
            segments_total=shelf.segments_total,
            dice_faces=dice_faces,
            instruction=(
                f"Go to your '{shelf.category_name}' section, "
                f"Section {shelf.segment}. "
                f"Pick {dice_faces} books from that shelf."
            ),
        )

    @app.post("/api/roll-die")
    def roll_die_endpoint(
        dice_faces: int | None = Query(default=None, ge=1),
    ) -> DieRollResponse:
        config = load_config(config_path)
        faces = (
            dice_faces if dice_faces is not None else config.settings.default_dice_faces
        )
        die_roll = roll_die(faces, random.Random())
        return DieRollResponse(
            die_roll=die_roll,
            die_faces=faces,
            die_glyph=format_die(die_roll, faces),
        )

    return app


def run_server(config_path: Path, port: int) -> None:
    uvicorn.run(create_app(config_path), host="127.0.0.1", port=port)
