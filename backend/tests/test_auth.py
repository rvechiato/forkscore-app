from jose import jwt

from src.app.settings import get_settings


def test_register_user_returns_token_and_user(client) -> None:
    response = client.post(
        "/auth/register",
        json={
            "name": "Rafa Vecchiato",
            "email": "rafa@example.com",
            "password": "super-secret-123",
        },
    )

    assert response.status_code == 201
    body = response.json()
    assert body["token_type"] == "bearer"
    assert body["user"]["name"] == "Rafa Vecchiato"
    assert body["user"]["email"] == "rafa@example.com"

    payload = jwt.decode(
        body["access_token"],
        get_settings().jwt_secret_key,
        algorithms=[get_settings().jwt_algorithm],
    )
    assert payload["sub"] == body["user"]["id"]


def test_register_user_rejects_duplicate_email(client) -> None:
    payload = {
        "name": "Rafa Vecchiato",
        "email": "rafa@example.com",
        "password": "super-secret-123",
    }

    first_response = client.post("/auth/register", json=payload)
    second_response = client.post("/auth/register", json=payload)

    assert first_response.status_code == 201
    assert second_response.status_code == 409
    assert second_response.json()["detail"] == "A user with this email already exists."


def test_login_returns_token_for_valid_credentials(client) -> None:
    register_payload = {
        "name": "Rafa Vecchiato",
        "email": "rafa@example.com",
        "password": "super-secret-123",
    }

    client.post("/auth/register", json=register_payload)

    response = client.post(
        "/auth/login",
        json={
            "email": register_payload["email"],
            "password": register_payload["password"],
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body["token_type"] == "bearer"
    assert body["user"]["email"] == register_payload["email"]
    assert body["access_token"]


def test_login_rejects_invalid_password(client) -> None:
    client.post(
        "/auth/register",
        json={
            "name": "Rafa Vecchiato",
            "email": "rafa@example.com",
            "password": "super-secret-123",
        },
    )

    response = client.post(
        "/auth/login",
        json={
            "email": "rafa@example.com",
            "password": "wrong-password",
        },
    )

    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid credentials."
