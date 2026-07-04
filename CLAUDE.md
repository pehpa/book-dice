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
