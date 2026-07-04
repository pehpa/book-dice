import re
from pathlib import Path

import pytest

from book_dice import cli
from book_dice.config import Category, Config, Settings, save_config


def test_main_runs_selection_and_creates_default_config(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    config_path = tmp_path / "config.json"

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 0
    assert config_path.exists()

    out = capsys.readouterr()
    assert "created a default" in out.err
    assert "🎲 book-dice SELECTION 🎲" in out.out
    assert re.search(r"\[STAGE 1\] Category:\s+.+\(Weight: \d+%\)", out.out)
    assert re.search(r"\[STAGE 2\] Segment:\s+Shelf Section \d+ \(of \d+\)", out.out)
    assert "Digital Roll Result" in out.out


def test_main_does_not_warn_when_config_already_exists(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=1, segments=1)}
        ),
    )

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 0
    out = capsys.readouterr()
    assert out.err == ""
    assert "Only" in out.out


def test_main_respects_dice_override(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=1, segments=1)}
        ),
    )

    exit_code = cli.main(["--config", str(config_path), "--dice", "8"])

    assert exit_code == 0
    out = capsys.readouterr()
    assert "Pick 8 books from that shelf." in out.out
    assert "Roll a W8 die to select your final book!" in out.out


def test_main_reports_error_on_empty_categories(
    tmp_path: Path, capsys: pytest.CaptureFixture[str]
) -> None:
    config_path = tmp_path / "config.json"
    save_config(config_path, Config(settings=Settings(), categories={}))

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 1
    out = capsys.readouterr()
    assert "Error:" in out.err


def test_main_ui_starts_web_server(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(web_port=1234),
            categories={"Only": Category(weight=1, segments=1)},
        ),
    )

    calls: list[tuple[Path, int]] = []
    monkeypatch.setattr(
        cli, "run_server", lambda path, port: calls.append((path, port))
    )

    exit_code = cli.main(["--config", str(config_path), "--ui"])

    assert exit_code == 0
    assert calls == [(config_path, 1234)]
