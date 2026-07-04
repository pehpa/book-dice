"""Command-line interface for book-dice."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from book_dice.config import DEFAULT_CONFIG_PATH, load_config
from book_dice.core import SelectionResult, format_die, run_selection
from book_dice.web import run_server


def format_result(result: SelectionResult) -> str:
    weight_str = f"{result.weight_percent:.0f}%"
    lines = [
        "🎲 book-dice SELECTION 🎲",
        "-" * 38,
        f"[STAGE 1] Category:  {result.category_name} (Weight: {weight_str})",
        f"[STAGE 2] Segment:   Shelf Section {result.segment} "
        f"(of {result.segments_total})",
        "-" * 38,
        "👉 INSTRUCTION:",
        f"Go to your '{result.category_name}' section, Section {result.segment}.",
        f"Pick {result.die_faces} books from that shelf.",
        f"Roll a W{result.die_faces} die to select your final book!",
        "",
        "[Digital Roll Result]: Your digital die landed on: "
        f"{format_die(result.die_roll, result.die_faces)}",
    ]
    return "\n".join(lines)


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

    try:
        result = run_selection(config, dice_faces=args.dice)
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    print(format_result(result))
    return 0
