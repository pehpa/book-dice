"""Command-line interface for book-dice."""

from __future__ import annotations

import argparse
import random
import sys
from pathlib import Path

from book_dice.config import DEFAULT_CONFIG_PATH, load_config
from book_dice.core import ShelfSelection, format_die, roll_die, select_shelf
from book_dice.web import run_server


def format_shelf_selection(shelf: ShelfSelection, dice_faces: int) -> str:
    weight_str = f"{shelf.weight_percent:.0f}%"
    lines = [
        "🎲 book-dice SELECTION 🎲",
        "-" * 38,
        f"[STAGE 1] Category:  {shelf.category_name} (Weight: {weight_str})",
        f"[STAGE 2] Segment:   Shelf Section {shelf.segment} "
        f"(of {shelf.segments_total})",
        "-" * 38,
        "👉 INSTRUCTION:",
        f"Go to your '{shelf.category_name}' section, Section {shelf.segment}.",
        f"Pick {dice_faces} books from that shelf.",
    ]
    return "\n".join(lines)


def format_die_result(die_roll: int, dice_faces: int) -> str:
    return f"You selected book number: {format_die(die_roll, dice_faces)}"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="book-dice", description="Pick your next book by rolling structural dice."
    )
    parser.add_argument(
        "--dice",
        type=int,
        default=None,
        help="Override the number of dice faces for this roll.",
    )
    parser.add_argument(
        "--ui",
        action="store_true",
        help="Start the local web UI instead of running a selection.",
    )
    parser.add_argument(
        "--config", type=Path, default=DEFAULT_CONFIG_PATH, help="Path to config.json."
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    config_existed = args.config.exists()
    config = load_config(args.config)
    if not config_existed:
        print(
            f"No config found — created a default one at {args.config}", file=sys.stderr
        )

    if args.ui:
        run_server(args.config, port=config.settings.web_port)
        return 0

    dice_faces = (
        args.dice if args.dice is not None else config.settings.default_dice_faces
    )
    if dice_faces < 1:
        print("Error: dice faces must be at least 1", file=sys.stderr)
        return 1

    try:
        shelf = select_shelf(config)
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    print(format_shelf_selection(shelf, dice_faces))
    response = input(
        f"\nPress Enter to roll a W{dice_faces} die, "
        "or type how many books you actually picked: "
    ).strip()

    if response:
        try:
            dice_faces = int(response)
        except ValueError:
            print(f"Error: '{response}' is not a whole number", file=sys.stderr)
            return 1
        if dice_faces < 1:
            print("Error: number of books must be at least 1", file=sys.stderr)
            return 1

    die_roll = roll_die(dice_faces, random.Random())
    print(format_die_result(die_roll, dice_faces))
    return 0
