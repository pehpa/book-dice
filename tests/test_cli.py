import re
from pathlib import Path

import pytest

from book_dice import cli
from book_dice.config import Category, Config, Settings, save_config


def test_main_runs_selection_and_creates_default_config(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    config_path = tmp_path / "config.json"
    monkeypatch.setattr("builtins.input", lambda prompt="": "")

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 0
    assert config_path.exists()

    out = capsys.readouterr()
    assert "created a default" in out.err
    assert "🎲 book-dice SELECTION 🎲" in out.out
    assert re.search(r"\[STAGE 1\] Category:\s+.+\(Weight: \d+%\)", out.out)
    assert re.search(r"\[STAGE 2\] Segment:\s+Shelf Section \d+ \(of \d+\)", out.out)
    assert "Pick 6 books from that shelf." in out.out
    assert "Digital Roll Result" in out.out


def test_main_waits_for_confirmation_before_rolling_die(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=100, segments=1)}
        ),
    )

    prompts: list[str] = []

    def fake_input(prompt: str = "") -> str:
        prompts.append(prompt)
        print(prompt, end="")
        return ""

    monkeypatch.setattr("builtins.input", fake_input)

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 0
    assert len(prompts) == 1
    assert "Press Enter" in prompts[0]

    out = capsys.readouterr()
    before_prompt, after_prompt = out.out.split(prompts[0])
    assert "Pick" in before_prompt
    assert "Digital Roll Result" not in before_prompt
    assert "Digital Roll Result" in after_prompt


def test_main_does_not_warn_when_config_already_exists(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=1, segments=1)}
        ),
    )
    monkeypatch.setattr("builtins.input", lambda prompt="": "")

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 0
    out = capsys.readouterr()
    assert out.err == ""
    assert "Only" in out.out


def test_main_respects_dice_override(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=1, segments=1)}
        ),
    )
    monkeypatch.setattr("builtins.input", lambda prompt="": "")

    exit_code = cli.main(["--config", str(config_path), "--dice", "8"])

    assert exit_code == 0
    out = capsys.readouterr()
    assert "Pick 8 books from that shelf." in out.out
    assert re.search(r"Your digital die landed on: \d+", out.out)


def test_main_allows_overriding_dice_faces_at_prompt(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=100, segments=1)}
        ),
    )
    monkeypatch.setattr("builtins.input", lambda prompt="": "3")

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 0
    out = capsys.readouterr()
    assert "Pick 6 books from that shelf." in out.out
    match = re.search(r"Your digital die landed on: (\d+)", out.out)
    assert match is not None
    assert 1 <= int(match.group(1)) <= 3


def test_main_rejects_non_numeric_override_at_prompt(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=100, segments=1)}
        ),
    )
    monkeypatch.setattr("builtins.input", lambda prompt="": "banana")

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 1
    out = capsys.readouterr()
    assert "Error:" in out.err


def test_main_rejects_zero_override_at_prompt(
    tmp_path: Path,
    capsys: pytest.CaptureFixture[str],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    config_path = tmp_path / "config.json"
    save_config(
        config_path,
        Config(
            settings=Settings(), categories={"Only": Category(weight=100, segments=1)}
        ),
    )
    monkeypatch.setattr("builtins.input", lambda prompt="": "0")

    exit_code = cli.main(["--config", str(config_path)])

    assert exit_code == 1
    out = capsys.readouterr()
    assert "Error:" in out.err


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
