from pathlib import Path

from fastapi.testclient import TestClient

from book_dice.config import Config, load_config
from book_dice.web import create_app


def make_client(tmp_path: Path) -> TestClient:
    return TestClient(create_app(tmp_path / "config.json"))


def test_index_serves_html(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    response = client.get("/")

    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    assert "book-dice" in response.text


def test_get_config_returns_default_on_first_access(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    response = client.get("/api/config")

    assert response.status_code == 200
    body = response.json()
    assert "Science Fiction" in body["categories"]
    assert body["settings"]["default_dice_faces"] == 6


def test_post_config_persists_to_disk(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    payload = {
        "settings": {"default_dice_faces": 6, "web_port": 5000},
        "categories": {"Test": {"weight": 100, "segments": 2}},
    }

    response = client.post("/api/config", json=payload)

    assert response.status_code == 200
    assert response.json()["categories"] == payload["categories"]

    saved = load_config(tmp_path / "config.json")
    assert saved == Config.model_validate(payload)


def test_post_config_rejects_invalid_payload(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    payload = {"categories": {"Bad": {"weight": 5, "segments": 0}}}

    response = client.post("/api/config", json=payload)

    assert response.status_code == 422


def test_post_config_rejects_weights_not_summing_to_100(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    payload = {
        "settings": {"default_dice_faces": 6, "web_port": 5000},
        "categories": {
            "A": {"weight": 30, "segments": 2},
            "B": {"weight": 30, "segments": 2},
        },
    }

    response = client.post("/api/config", json=payload)

    assert response.status_code == 400
    assert "sum to 100" in response.json()["detail"]


def test_post_select_shelf_returns_valid_selection(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    response = client.post("/api/select-shelf")

    assert response.status_code == 200
    body = response.json()
    assert body["category"] in {"Science Fiction", "Belletristik", "Sachbücher"}
    assert 1 <= body["segment"] <= body["segments_total"]
    assert body["dice_faces"] == 6
    assert body["category"] in body["instruction"]


def test_post_select_shelf_returns_400_when_no_categories_configured(
    tmp_path: Path,
) -> None:
    client = make_client(tmp_path)
    client.post(
        "/api/config",
        json={
            "settings": {"default_dice_faces": 6, "web_port": 5000},
            "categories": {},
        },
    )

    response = client.post("/api/select-shelf")

    assert response.status_code == 400


def test_post_roll_die_returns_valid_roll(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    response = client.post("/api/roll-die")

    assert response.status_code == 200
    body = response.json()
    assert body["die_faces"] == 6
    assert 1 <= body["die_roll"] <= body["die_faces"]
    assert body["die_glyph"]


def test_post_roll_die_respects_dice_faces_override(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    response = client.post("/api/roll-die?dice_faces=3")

    assert response.status_code == 200
    body = response.json()
    assert body["die_faces"] == 3
    assert 1 <= body["die_roll"] <= 3


def test_post_roll_die_rejects_dice_faces_below_one(tmp_path: Path) -> None:
    client = make_client(tmp_path)
    response = client.post("/api/roll-die?dice_faces=0")

    assert response.status_code == 422
