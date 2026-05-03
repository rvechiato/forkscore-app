from src.modules.places.infra.database.bootstrap import slugify_taxonomy, taxonomy_id


from datetime import UTC, datetime

from src.modules.reviews.infra.database.models import ReviewModel


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


def _create_review(client, token: str, place_id: str, payload: dict | None = None) -> dict:
    response = client.post(
        f"/places/{place_id}/reviews",
        headers={"Authorization": f"Bearer {token}"},
        json=_valid_review_payload() if payload is None else payload,
    )
    assert response.status_code == 201
    return response.json()


def _set_review_created_at(db_session, review_id: str, created_at: datetime) -> None:
    review = db_session.get(ReviewModel, review_id)
    assert review is not None
    review.created_at = created_at
    review.updated_at = created_at
    db_session.add(review)
    db_session.commit()


def test_create_review_returns_created_review(client, db_session) -> None:
    token, user = _register_and_get_token(client)
    place = _create_place(client, token)

    body = _create_review(client, token, place["id"])
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
    persisted = db_session.get(ReviewModel, body["id"])
    assert persisted is not None
    assert persisted.overall_rating == 3.6


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

    first_response = _create_review(client, token, place["id"])
    second_payload = _valid_review_payload()
    second_payload["recommendation"] = "not_recommended"
    second_response = _create_review(client, token, place["id"], second_payload)

    assert first_response["id"] != second_response["id"]
    assert second_response["recommendation"] == "not_recommended"


def test_get_place_reviews_summary_returns_empty_state(client) -> None:
    token, _ = _register_and_get_token(client)
    place = _create_place(client, token)

    response = client.get(
        f"/places/{place['id']}/reviews/summary",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "place_id": place["id"],
        "total_reviews": 0,
        "average_rating": None,
        "criteria_ratings": [
            {
                "code": "taste",
                "label": "Sabor",
                "average_rating": None,
                "total_reviews": 0,
            },
            {
                "code": "service",
                "label": "Atendimento",
                "average_rating": None,
                "total_reviews": 0,
            },
            {
                "code": "options",
                "label": "Opcoes",
                "average_rating": None,
                "total_reviews": 0,
            },
            {
                "code": "infrastructure",
                "label": "Infraestrutura",
                "average_rating": None,
                "total_reviews": 0,
            },
            {
                "code": "cost_benefit",
                "label": "Custo-beneficio",
                "average_rating": None,
                "total_reviews": 0,
            },
        ],
        "recommendation_summary": {
            "recommended_count": 0,
            "not_recommended_count": 0,
            "recommended_percentage": 0,
            "not_recommended_percentage": 0,
        },
        "recent_reviews": [],
    }


def test_get_place_reviews_summary_returns_404_for_unknown_place(client) -> None:
    token, _ = _register_and_get_token(client)

    response = client.get(
        "/places/00000000-0000-0000-0000-000000000000/reviews/summary",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found."


def test_list_place_reviews_returns_empty_list(client) -> None:
    token, _ = _register_and_get_token(client)
    place = _create_place(client, token)

    response = client.get(
        f"/places/{place['id']}/reviews",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 200
    assert response.json() == {
        "place_id": place["id"],
        "reviews": [],
    }


def test_list_place_reviews_returns_404_for_unknown_place(client) -> None:
    token, _ = _register_and_get_token(client)

    response = client.get(
        "/places/00000000-0000-0000-0000-000000000000/reviews",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Place not found."


def test_get_place_reviews_summary_returns_average_and_recent_reviews(client, db_session) -> None:
    owner_token, _ = _register_and_get_token(client)
    reviewer_two_token, _ = _register_and_get_token(
        client,
        name="Joana Silva",
        email="joana@example.com",
    )
    reviewer_three_token, _ = _register_and_get_token(
        client,
        name="Carlos Souza",
        email="carlos@example.com",
    )
    reviewer_four_token, _ = _register_and_get_token(
        client,
        name="Marina Lima",
        email="marina@example.com",
    )
    place = _create_place(client, owner_token)

    payload_one = _valid_review_payload()
    payload_two = _valid_review_payload()
    payload_two["cost_benefit_rating"] = 5
    payload_two["criteria"][0]["rating"] = 4
    payload_two["criteria"][1]["rating"] = 4
    payload_two["criteria"][2]["rating"] = 4
    payload_two["criteria"][3]["rating"] = 4
    payload_two["criteria"][1]["comment"] = "Servico rapido e cordial."
    payload_two["recommendation"] = "not_recommended"

    payload_three = _valid_review_payload()
    payload_three["cost_benefit_rating"] = 2
    payload_three["criteria"][0]["rating"] = 2
    payload_three["criteria"][0]["justification"] = "Sabor inconsistente na visita."
    payload_three["criteria"][1]["rating"] = 3
    payload_three["criteria"][2]["rating"] = 3
    payload_three["criteria"][3]["rating"] = 2
    payload_three["criteria"][3]["justification"] = "Espaco apertado e pouco confortavel."
    payload_three["recommendation"] = "not_recommended"

    payload_four = _valid_review_payload()
    payload_four["cost_benefit_rating"] = 1
    payload_four["criteria"][0]["rating"] = 1
    payload_four["criteria"][0]["justification"] = "Receita desequilibrada."
    payload_four["criteria"][1]["rating"] = 2
    payload_four["criteria"][1]["justification"] = "Atendimento confuso."
    payload_four["criteria"][2]["rating"] = 2
    payload_four["criteria"][2]["justification"] = "Cardapio repetitivo."
    payload_four["criteria"][3]["rating"] = 2
    payload_four["criteria"][3]["justification"] = "Mesas sem manutencao."
    payload_four["recommendation"] = "not_recommended"

    review_one = _create_review(client, owner_token, place["id"], payload_one)
    review_two = _create_review(client, reviewer_two_token, place["id"], payload_two)
    review_three = _create_review(client, reviewer_three_token, place["id"], payload_three)
    review_four = _create_review(client, reviewer_four_token, place["id"], payload_four)

    _set_review_created_at(db_session, review_one["id"], datetime(2026, 4, 28, 12, 0, tzinfo=UTC))
    _set_review_created_at(db_session, review_two["id"], datetime(2026, 4, 28, 13, 0, tzinfo=UTC))
    _set_review_created_at(db_session, review_three["id"], datetime(2026, 4, 28, 14, 0, tzinfo=UTC))
    _set_review_created_at(db_session, review_four["id"], datetime(2026, 4, 28, 15, 0, tzinfo=UTC))

    response = client.get(
        f"/places/{place['id']}/reviews/summary",
        headers={"Authorization": f"Bearer {owner_token}"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["place_id"] == place["id"]
    assert body["total_reviews"] == 4
    assert body["average_rating"] == 2.95
    assert body["criteria_ratings"] == [
        {
            "code": "taste",
            "label": "Sabor",
            "average_rating": 3.0,
            "total_reviews": 4,
        },
        {
            "code": "service",
            "label": "Atendimento",
            "average_rating": 3.25,
            "total_reviews": 4,
        },
        {
            "code": "options",
            "label": "Opcoes",
            "average_rating": 2.75,
            "total_reviews": 4,
        },
        {
            "code": "infrastructure",
            "label": "Infraestrutura",
            "average_rating": 2.75,
            "total_reviews": 4,
        },
        {
            "code": "cost_benefit",
            "label": "Custo-beneficio",
            "average_rating": 3.0,
            "total_reviews": 4,
        },
    ]
    assert body["recommendation_summary"] == {
        "recommended_count": 1,
        "not_recommended_count": 3,
        "recommended_percentage": 25,
        "not_recommended_percentage": 75,
    }
    assert [item["id"] for item in body["recent_reviews"]] == [
        review_four["id"],
        review_three["id"],
        review_two["id"],
    ]
    assert body["recent_reviews"][0]["user"]["name"] == "Marina Lima"
    assert body["recent_reviews"][0]["recommendation"] == "not_recommended"
    assert body["recent_reviews"][0]["overall_rating"] == 1.6
    assert [criterion["code"] for criterion in body["recent_reviews"][0]["criteria"]] == [
        "taste",
        "service",
        "options",
        "infrastructure",
    ]


def test_get_place_reviews_summary_rounds_recommendation_percentages(client) -> None:
    owner_token, _ = _register_and_get_token(client)
    reviewer_two_token, _ = _register_and_get_token(
        client,
        name="Joana Silva",
        email="joana-percent@example.com",
    )
    reviewer_three_token, _ = _register_and_get_token(
        client,
        name="Carlos Souza",
        email="carlos-percent@example.com",
    )
    place = _create_place(client, owner_token)

    _create_review(client, owner_token, place["id"])
    not_recommended_payload = _valid_review_payload()
    not_recommended_payload["recommendation"] = "not_recommended"
    _create_review(client, reviewer_two_token, place["id"], not_recommended_payload)
    _create_review(client, reviewer_three_token, place["id"], not_recommended_payload)

    response = client.get(
        f"/places/{place['id']}/reviews/summary",
        headers={"Authorization": f"Bearer {owner_token}"},
    )

    assert response.status_code == 200
    recommendation_summary = response.json()["recommendation_summary"]
    assert recommendation_summary == {
        "recommended_count": 1,
        "not_recommended_count": 2,
        "recommended_percentage": 33,
        "not_recommended_percentage": 67,
    }
    assert (
        recommendation_summary["recommended_percentage"]
        + recommendation_summary["not_recommended_percentage"]
        == 100
    )


def test_list_place_reviews_returns_all_reviews_newest_first(client, db_session) -> None:
    owner_token, _ = _register_and_get_token(client)
    reviewer_two_token, _ = _register_and_get_token(
        client,
        name="Joana Silva",
        email="joana-list@example.com",
    )
    reviewer_three_token, _ = _register_and_get_token(
        client,
        name="Carlos Souza",
        email="carlos-list@example.com",
    )
    reviewer_four_token, _ = _register_and_get_token(
        client,
        name="Marina Lima",
        email="marina-list@example.com",
    )
    place = _create_place(client, owner_token)

    review_one = _create_review(client, owner_token, place["id"])
    review_two = _create_review(client, reviewer_two_token, place["id"])
    review_three = _create_review(client, reviewer_three_token, place["id"])
    review_four = _create_review(client, reviewer_four_token, place["id"])

    _set_review_created_at(db_session, review_one["id"], datetime(2026, 4, 28, 12, 0, tzinfo=UTC))
    _set_review_created_at(db_session, review_two["id"], datetime(2026, 4, 28, 13, 0, tzinfo=UTC))
    _set_review_created_at(db_session, review_three["id"], datetime(2026, 4, 28, 14, 0, tzinfo=UTC))
    _set_review_created_at(db_session, review_four["id"], datetime(2026, 4, 28, 15, 0, tzinfo=UTC))

    response = client.get(
        f"/places/{place['id']}/reviews",
        headers={"Authorization": f"Bearer {owner_token}"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["place_id"] == place["id"]
    assert [item["id"] for item in body["reviews"]] == [
        review_four["id"],
        review_three["id"],
        review_two["id"],
        review_one["id"],
    ]
    assert body["reviews"][0]["user"]["name"] == "Marina Lima"
    assert body["reviews"][0]["overall_rating"] == 3.6
