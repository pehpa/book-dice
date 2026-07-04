# book-dice

book-dice solves a very specific kind of indecision: you own more books than
you can realistically choose between, and every time you stand in front of
the shelf you end up rereading spines for ten minutes instead of reading a
book. Instead of picking, you let the tool pick for you.

You tell it about the shelf categories you actually have (say, "Science
Fiction", "Belletristik", "Sachbücher"), how much you want each one weighted,
and how many physical sections each category spans. When you ask for a
selection, book-dice rolls a weighted die to choose a category, rolls again
to pick a shelf section within it, and tells you to go stand in front of that
section and pull a handful of books. Only once you've actually picked those
books do you roll a final die to decide which one you're reading — the tool
deliberately splits "which shelf" from "which book" into two separate steps,
so you go stand in front of the shelf before committing to a final number.

It ships as both a command-line tool and a small local web UI, backed by the
same `config.json` and the same selection logic either way.

## How a selection works

1. **Pick a shelf.** book-dice picks a category at random, weighted by the
   percentages you configured, then picks a random section within that
   category (e.g. "Science Fiction, Section 3 of 4").
2. **Pick your books.** You go to that physical shelf section and pull out
   as many books as your configured dice-face count says (6 by default) —
   or however many you actually find there, since shelves don't always
   cooperate with configuration files.
3. **Roll for the winner.** Once you confirm you've made your pile of
   candidate books, book-dice rolls a die sized to however many books you
   actually picked and gives you the number of your next read.

## Setup

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```

## Usage

### Command line

Running book-dice with no arguments walks you through a selection
interactively. On first run it creates a `config.json` in the current
directory with a small set of example categories, so there's something to
roll against immediately:

```bash
python -m book_dice
```

It prints the chosen category and shelf section, then waits for you to
confirm — press Enter to roll using the configured number of books, or type
a different number if you picked more or fewer than expected. If you want a
different default book count than `config.json` specifies for this run only,
pass it up front:

```bash
python -m book_dice --dice 8
```

Point it at a config file somewhere other than the current directory:

```bash
python -m book_dice --config path/to/config.json
```

### Web interface

The same logic is available through a small FastAPI-backed page, useful if
you'd rather click a button than run a command, or want to edit your
categories through a form instead of hand-editing JSON:

```bash
python -m book_dice --ui
```

This starts a local server (default `http://127.0.0.1:5000`) with two
screens: a generator view that mirrors the CLI flow (pick a shelf, then roll
once you've gathered your books), and a config view for adding, removing, and
re-weighting categories without touching `config.json` directly.

## Configuration

`config.json` has two parts: `settings` (the default number of dice faces to
assume per shelf, and which port the web UI listens on) and `categories` — a
map of category name to `weight` (its share of the 100% pool of odds) and
`segments` (how many physical sections that category spans on your shelf).
Category weights must add up to 100 when saved through the web UI, and both
interfaces let you override the dice-face count for a single roll without
changing what's saved to disk.

## Development

Run tests:

```bash
pytest
```

Lint and format:

```bash
ruff check .
ruff format .
```

Type check:

```bash
mypy src
```
