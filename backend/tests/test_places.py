def _register_and_get_token(
    client,
    *,
    name: str = "Rafa Vecchiato",
    email: str = "rafa@example.com",
) -> tuple[str, dict]:
    response = client.post(
        "/auth/register",
        json={
            "name": name,
            "email": email,
            "password": "super-secret-123",
        },
    )
    assert response.status_code == 201
    body = response.json()
    return body["access_token"], body["user"]


def test_create_place_registers_authenticated_author(client) -> None:
    token, user = _register_and_get_token(client)

    response = client.post(
        "/places",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "name": "Cafe do Centro",
            "street": "Rua das Flores",
            "number": "123",
            "neighborhood": "Centro",
            "city": "Curitiba",
        },
    )

    assert response.status_code == 201
    body = response.json()
    assert body["name"] == "Cafe do Centro"
    assert body["street"] == "Rua das Flores"
    assert body["number"] == "123"
    assert body["neighborhood"] == "Centro"
    assert body["city"] == "Curitiba"
    assert body["created_by"]["id"] == user["id"]
    assert body["created_by"]["name"] == "Rafa Vecchiato"


def test_create_place_requires_authentication(client) -> None:
    response = client.post(
        "/places",
        json={
            "name": "Cafe do Centro",
            "street": "Rua das Flores",
            "number": "123",
            "neighborhood": "Centro",
            "city": "Curitiba",
        },
    )

    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated."


def test_create_place_rejects_missing_required_fields(client) -> None:
    token, _ = _register_and_get_token(client)

    response = client.post(
        "/places",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "name": "Cafe do Centro",
            "street": "Rua das Flores",
            "number": "123",
            "neighborhood": "Centro",
        },
    )

    assert response.status_code == 422


def test_list_places_returns_registered_places(client) -> None:
    first_token, first_user = _register_and_get_token(
        client,
        name="Rafa Vecchiato",
        email="rafa@example.com",
    )
    second_token, second_user = _register_and_get_token(
        client,
        name="Pat Martins",
        email="pat@example.com",
    )

    client.post(
        "/places",
        headers={"Authorization": f"Bearer {first_token}"},
        json={
            "name": "Cafe do Centro",
            "street": "Rua das Flores",
            "number": "123",
            "neighborhood": "Centro",
            "city": "Curitiba",
        },
    )
    client.post(
        "/places",
        headers={"Authorization": f"Bearer {second_token}"},
        json={
            "name": "Padaria da Vila",
            "street": "Avenida Principal",
            "number": "987",
            "neighborhood": "Vila Nova",
            "city": "Joinville",
        },
    )

    response = client.get(
        "/places",
        headers={"Authorization": f"Bearer {first_token}"},
    )

    assert response.status_code == 200
    body = response.json()
    assert len(body) == 2
    assert body[0]["name"] == "Padaria da Vila"
    assert body[0]["created_by"]["id"] == second_user["id"]
    assert body[0]["created_by"]["name"] == "Pat Martins"
    assert body[1]["name"] == "Cafe do Centro"
    assert body[1]["created_by"]["id"] == first_user["id"]


def test_get_place_by_id_returns_place_detail(client) -> None:
    token, user = _register_and_get_token(client)
    create_response = client.post(
        "/places",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "name": "Cafe do Centro",
            "street": "Rua das Flores",
            "number": "123",
            "neighborhood": "Centro",
            "city": "Curitiba",
        },
    )
    place_id = create_response.json()["id"]

    response = client.get(
        f"/places/{place_id}",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["id"] == place_id
    assert body["name"] == "Cafe do Centro"
    assert body["created_by"]["id"] == user["id"]
    assert body["created_by"]["name"] == "Rafa Vecchiato"


def test_get_place_by_id_returns_404_for_unknown_place(client) -> None:
    token, _ = _register_and_get_token(client)

    response = client.get(
        "/places/00000000-0000-0000-0000-000000000000",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found."
