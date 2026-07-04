"""Pure selection logic: weighted category, uniform segment, and die roll."""

from __future__ import annotations

import random
from dataclasses import dataclass

from book_dice.config import Category, Config


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
class ShelfSelection:
    category_name: str
    weight_percent: float
    segment: int
    segments_total: int


def select_shelf(
    config: Config,
    rng: random.Random | None = None,
) -> ShelfSelection:
    if rng is None:
        rng = random.Random()

    category_name = pick_category(config.categories, rng)
    category = config.categories[category_name]
    total_weight = sum(c.weight for c in config.categories.values())
    weight_percent = (category.weight / total_weight) * 100

    segment = pick_segment(category.segments, rng)

    return ShelfSelection(
        category_name=category_name,
        weight_percent=weight_percent,
        segment=segment,
        segments_total=category.segments,
    )
