def _register_and_get_token(client, email: str = "rafa@example.com") -> str:
    response = client.post(
        "/auth/register",
        json={
            "name": "Rafa Vecchiato",
            "birth_date": "1991-03-05",
            "email": email,
            "password": "super-secret-123",
        },
    )
    assert response.status_code == 201
    return response.json()["access_token"]


def test_get_my_profile_returns_authenticated_profile(client) -> None:
    token = _register_and_get_token(client)

    response = client.get(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["name"] == "Rafa Vecchiato"
    assert body["birth_date"] == "1991-03-05"
    assert body["age"] >= 18
    assert body["email"] == "rafa@example.com"


def test_get_my_profile_requires_authentication(client) -> None:
    response = client.get("/me")

    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated."


def test_update_my_profile_updates_name_birth_date_and_email(client) -> None:
    token = _register_and_get_token(client)

    response = client.put(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "name": "Rafa Atualizado",
            "birth_date": "1992-08-17",
            "email": "rafa.atualizado@example.com",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body["name"] == "Rafa Atualizado"
    assert body["birth_date"] == "1992-08-17"
    assert body["email"] == "rafa.atualizado@example.com"


def test_update_my_profile_rejects_duplicated_email(client) -> None:
    token = _register_and_get_token(client, email="rafa@example.com")
    _register_and_get_token(client, email="outro@example.com")

    response = client.put(
        "/me",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "name": "Rafa Atualizado",
            "birth_date": "1992-08-17",
            "email": "outro@example.com",
        },
    )

    assert response.status_code == 409
    assert response.json()["detail"] == "A user with this email already exists."
