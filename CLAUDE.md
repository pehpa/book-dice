# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install (editable + dev deps)
pip install -e ".[dev]"

# Run all tests
pytest

# Run a single test
pytest tests/test_foo.py::test_bar

# Lint
ruff check .

# Format
ruff format .

# Type check
mypy src
```

## Architecture

`src` layout: the package lives at `src/book_dice/` and is installed as `book_dice`. Tests live in `tests/`. Build backend is hatchling. Python ≥ 3.11 required, mypy strict mode enforced.

- `config.py` — pydantic `Config`/`Settings`/`Category` models plus `load_config`/`save_config`. `config.json` is created with defaults on first run and is gitignored. `Settings.default_dice_faces` and `Category.segments` both require `>= 1`; `Category.weight` requires `>= 0`.
- `core.py` — pure selection logic, no I/O: `pick_category`, `pick_segment`, `roll_die`, and `select_shelf` (combines the first two into a `ShelfSelection`). All take an explicit `random.Random` (or default to an unseeded one), which is what makes them testable with fixed seeds.
- `cli.py` — argparse entry point. Selection is a deliberate two-phase interactive flow: print the shelf/category pick, then `input()` blocks until the user presses Enter (roll with the default/`--dice` count) or types a number (one-off override for that roll only). Tests must `monkeypatch.setattr("builtins.input", ...)`.
- `web.py` — FastAPI app mirroring the same two phases as separate endpoints: `POST /api/select-shelf` (category + segment, no roll) and `POST /api/roll-die` (optional `?dice_faces=` query override). `GET/POST /api/config` reads/writes `config.json`; saving via the API rejects category weights that don't sum to 100 (skipped if there are zero categories).
- `static/index.html` — single-file frontend (Tailwind via CDN script, not a production build), served directly by the `/` route. No other static assets are currently mounted.
