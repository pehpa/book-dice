import random
from collections import Counter

import pytest

from book_dice.config import Category, Config, Settings
from book_dice.core import (
    DIE_GLYPHS,
    format_die,
    pick_category,
    pick_segment,
    roll_die,
    run_selection,
)


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


def test_format_die_uses_glyph_for_six_sided() -> None:
    for roll, glyph in DIE_GLYPHS.items():
        assert format_die(roll, 6) == f"{glyph} ({roll})"


def test_format_die_uses_plain_number_for_other_faces() -> None:
    assert format_die(5, 8) == "5"


def test_run_selection_returns_valid_result() -> None:
    config = Config(
        settings=Settings(default_dice_faces=6, web_port=5000),
        categories={
            "Science Fiction": Category(weight=50, segments=4),
            "Belletristik": Category(weight=20, segments=6),
        },
    )
    result = run_selection(config, rng=random.Random(7))

    assert result.category_name in config.categories
    category = config.categories[result.category_name]
    assert 1 <= result.segment <= category.segments
    assert result.segments_total == category.segments
    assert 1 <= result.die_roll <= 6
    assert result.die_faces == 6
    assert result.weight_percent == pytest.approx((category.weight / 70) * 100)


def test_run_selection_respects_dice_faces_override() -> None:
    config = Config(
        settings=Settings(default_dice_faces=6, web_port=5000),
        categories={"Only": Category(weight=1, segments=1)},
    )
    result = run_selection(config, dice_faces=8, rng=random.Random(3))

    assert result.die_faces == 8
    assert 1 <= result.die_roll <= 8


def test_run_selection_raises_on_empty_categories() -> None:
    config = Config(settings=Settings(), categories={})
    with pytest.raises(ValueError):
        run_selection(config, rng=random.Random(0))
