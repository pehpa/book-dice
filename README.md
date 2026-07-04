# book-dice

## Setup

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```

## Usage

Roll a selection using `config.json` in the current directory (created automatically on first run):

```bash
python -m book_dice
```

Override the number of dice faces for a single roll:

```bash
python -m book_dice --dice 8
```

Start the local web UI instead:

```bash
python -m book_dice --ui
```

Use a config file at a different path:

```bash
python -m book_dice --config path/to/config.json
```

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
