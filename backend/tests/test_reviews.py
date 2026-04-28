from src.modules.places.infra.database.bootstrap import slugify_taxonomy, taxonomy_id


def _category_id(name: str) -> str:
    return taxonomy_id("category", slugify_taxonomy(name))


def _subcategory_id(category_name: str, subcategory_name: str) -> str:
    return taxonomy_id(
        "subcategory",
        slugify_taxonomy(category_name),
        slugify_taxonomy(subcategory_name),
    )


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


def _create_place(client, token: str) -> dict:
    response = client.post(
        "/places",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "name": "Cafe do Centro",
            "street": "Rua das Flores",
            "number": "123",
            "neighborhood": "Centro",
            "city": "Curitiba",
            "category_id": _category_id("Cafeteria"),
            "subcategory_id": _subcategory_id("Cafeteria", "Doceria"),
        },
    )
    assert response.status_code == 201
    return response.json()


def _valid_review_payload() -> dict:
    return {
        "recommendation": "recommended",
        "cost_benefit_rating": 4,
        "criteria": [
            {
                "code": "taste",
                "rating": 5,
                "comment": "Pratos bem executados e sabor equilibrado.",
                "justification": None,
            },
            {
                "code": "service",
                "rating": 4,
                "comment": "Equipe atenciosa e agilidade adequada.",
                "justification": None,
            },
            {
                "code": "options",
                "rating": 2,
                "comment": "Poucas opcoes vegetarianas no cardapio.",
                "justification": "O cardapio tem variedade limitada para restricoes alimentares.",
            },
            {
                "code": "infrastructure",
                "rating": 3,
                "comment": "Ambiente confortavel e limpo.",
                "justification": None,
            },
        ],
    }


def test_create_review_returns_created_review(client) -> None:
    token, user = _register_and_get_token(client)
    place = _create_place(client, token)

    response = client.post(
        f"/places/{place['id']}/reviews",
        headers={"Authorization": f"Bearer {token}"},
        json=_valid_review_payload(),
    )

    assert response.status_code == 201
    body = response.json()
    assert body["place_id"] == place["id"]
    assert body["user"]["id"] == user["id"]
    assert body["user"]["name"] == user["name"]
    assert body["recommendation"] == "recommended"
    assert body["cost_benefit_rating"] == 4
    assert [criterion["code"] for criterion in body["criteria"]] == [
        "taste",
        "service",
        "options",
        "infrastructure",
    ]


def test_create_review_requires_authentication(client) -> None:
    token, _ = _register_and_get_token(client)
    place = _create_place(client, token)

    response = client.post(
        f"/places/{place['id']}/reviews",
        json=_valid_review_payload(),
    )

    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated."


def test_create_review_returns_404_for_unknown_place(client) -> None:
    token, _ = _register_and_get_token(client)

    response = client.post(
        "/places/00000000-0000-0000-0000-000000000000/reviews",
        headers={"Authorization": f"Bearer {token}"},
        json=_valid_review_payload(),
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found."


def test_create_review_rejects_missing_justification_for_low_rating(client) -> None:
    token, _ = _register_and_get_token(client)
    place = _create_place(client, token)
    payload = _valid_review_payload()
    payload["criteria"][2]["justification"] = None

    response = client.post(
        f"/places/{place['id']}/reviews",
        headers={"Authorization": f"Bearer {token}"},
        json=payload,
    )

    assert response.status_code == 422
    assert (
        response.json()["detail"]
        == "Criterion justification is required when rating is below 3."
    )


def test_create_review_rejects_duplicate_criteria(client) -> None:
    token, _ = _register_and_get_token(client)
    place = _create_place(client, token)
    payload = _valid_review_payload()
    payload["criteria"][3]["code"] = "taste"

    response = client.post(
        f"/places/{place['id']}/reviews",
        headers={"Authorization": f"Bearer {token}"},
        json=payload,
    )

    assert response.status_code == 422
    assert response.json()["detail"] == "A review must contain all four required criteria."


def test_create_review_accepts_multiple_reviews_for_same_user_and_place(client) -> None:
    token, _ = _register_and_get_token(client)
    place = _create_place(client, token)

    first_response = client.post(
        f"/places/{place['id']}/reviews",
        headers={"Authorization": f"Bearer {token}"},
        json=_valid_review_payload(),
    )
    second_payload = _valid_review_payload()
    second_payload["recommendation"] = "not_recommended"
    second_response = client.post(
        f"/places/{place['id']}/reviews",
        headers={"Authorization": f"Bearer {token}"},
        json=second_payload,
    )

    assert first_response.status_code == 201
    assert second_response.status_code == 201
    assert first_response.json()["id"] != second_response.json()["id"]
    assert second_response.json()["recommendation"] == "not_recommended"
