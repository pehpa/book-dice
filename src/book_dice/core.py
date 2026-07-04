"""Pure selection logic: weighted category, uniform segment, and die roll."""

from __future__ import annotations

import random
from dataclasses import dataclass

from book_dice.config import Category, Config

DIE_GLYPHS = {
    1: "⚀",
    2: "⚁",
    3: "⚂",
    4: "⚃",
    5: "⚄",
    6: "⚅",
}


def format_die(roll: int, faces: int) -> str:
    if faces == 6 and roll in DIE_GLYPHS:
        return f"{DIE_GLYPHS[roll]} ({roll})"
    return str(roll)


def pick_category(categories: dict[str, Category], rng: random.Random) -> str:
    if not categories:
        raise ValueError("no categories configured")
    names = list(categories)
    weights = [categories[name].weight for name in names]
    if sum(weights) <= 0:
        raise ValueError("category weights must sum to a positive number")
    return rng.choices(names, weights=weights, k=1)[0]


def pick_segment(segments: int, rng: random.Random) -> int:
    if segments < 1:
        raise ValueError("segments must be at least 1")
    return rng.randint(1, segments)


def roll_die(faces: int, rng: random.Random) -> int:
    if faces < 1:
        raise ValueError("dice faces must be at least 1")
    return rng.randint(1, faces)


@dataclass
class SelectionResult:
    category_name: str
    weight_percent: float
    segment: int
    segments_total: int
    die_roll: int
    die_faces: int


def run_selection(
    config: Config,
    dice_faces: int | None = None,
    rng: random.Random | None = None,
) -> SelectionResult:
    if rng is None:
        rng = random.Random()
    faces = dice_faces if dice_faces is not None else config.settings.default_dice_faces

    category_name = pick_category(config.categories, rng)
    category = config.categories[category_name]
    total_weight = sum(c.weight for c in config.categories.values())
    weight_percent = (category.weight / total_weight) * 100

    segment = pick_segment(category.segments, rng)
    die_roll = roll_die(faces, rng)

    return SelectionResult(
        category_name=category_name,
        weight_percent=weight_percent,
        segment=segment,
        segments_total=category.segments,
        die_roll=die_roll,
        die_faces=faces,
    )
