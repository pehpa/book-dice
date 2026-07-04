"""FastAPI web UI for book-dice."""

from __future__ import annotations

from pathlib import Path

import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel

from book_dice.config import Config, load_config, save_config
from book_dice.core import format_die, run_selection

STATIC_DIR = Path(__file__).parent / "static"


class RollResponse(BaseModel):
    category: str
    weight_percent: float
    segment: int
    segments_total: int
    die_roll: int
    die_faces: int
    die_glyph: str
    instruction: str


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
        save_config(config_path, config)
        return config

    @app.post("/api/roll")
    def roll() -> RollResponse:
        config = load_config(config_path)
        try:
            result = run_selection(config)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc

        return RollResponse(
            category=result.category_name,
            weight_percent=result.weight_percent,
            segment=result.segment,
            segments_total=result.segments_total,
            die_roll=result.die_roll,
            die_faces=result.die_faces,
            die_glyph=format_die(result.die_roll, result.die_faces),
            instruction=(
                f"Go to your '{result.category_name}' section, "
                f"Section {result.segment}. "
                f"Pick {result.die_faces} books from that shelf. "
                f"Roll a W{result.die_faces} die to select your final book!"
            ),
        )

    return app


def run_server(config_path: Path, port: int) -> None:
    uvicorn.run(create_app(config_path), host="127.0.0.1", port=port)
