import random
from collections import Counter

import pytest

from book_dice.config import Category, Config, Settings
from book_dice.core import pick_category, pick_segment, roll_die, select_shelf


def test_pick_category_respects_weights_within_tolerance() -> None:
    categories = {
        "A": Category(weight=50, segments=1),
        "B": Category(weight=20, segments=1),
        "C": Category(weight=30, segments=1),
    }
    rng = random.Random(42)
    counts: Counter[str] = Counter(
        pick_category(categories, rng) for _ in range(20_000)
    )

    total = sum(counts.values())
    assert counts["A"] / total == pytest.approx(0.5, abs=0.02)
    assert counts["B"] / total == pytest.approx(0.2, abs=0.02)
    assert counts["C"] / total == pytest.approx(0.3, abs=0.02)


def test_pick_category_raises_on_empty_categories() -> None:
    with pytest.raises(ValueError):
        pick_category({}, random.Random())


def test_pick_category_raises_on_zero_total_weight() -> None:
    categories = {"A": Category(weight=0, segments=1)}
    with pytest.raises(ValueError):
        pick_category(categories, random.Random())


def test_pick_segment_bounds() -> None:
    rng = random.Random(1)
    results = {pick_segment(4, rng) for _ in range(500)}
    assert results == {1, 2, 3, 4}


def test_pick_segment_raises_on_invalid_segments() -> None:
    with pytest.raises(ValueError):
        pick_segment(0, random.Random())


def test_roll_die_bounds() -> None:
    rng = random.Random(2)
    results = {roll_die(6, rng) for _ in range(500)}
    assert results == {1, 2, 3, 4, 5, 6}


def test_roll_die_raises_on_invalid_faces() -> None:
    with pytest.raises(ValueError):
        roll_die(0, random.Random())


def test_select_shelf_returns_valid_result() -> None:
    config = Config(
        settings=Settings(default_dice_faces=6, web_port=5000),
        categories={
            "Science Fiction": Category(weight=50, segments=4),
            "Belletristik": Category(weight=20, segments=6),
        },
    )
    shelf = select_shelf(config, rng=random.Random(7))

    assert shelf.category_name in config.categories
    category = config.categories[shelf.category_name]
    assert 1 <= shelf.segment <= category.segments
    assert shelf.segments_total == category.segments
    assert shelf.weight_percent == pytest.approx((category.weight / 70) * 100)


def test_select_shelf_raises_on_empty_categories() -> None:
    config = Config(settings=Settings(), categories={})
    with pytest.raises(ValueError):
        select_shelf(config, rng=random.Random(0))
