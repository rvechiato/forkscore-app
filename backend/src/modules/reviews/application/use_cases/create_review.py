from datetime import UTC, datetime
from uuid import uuid4

from src.modules.places.domain.errors import PlaceNotFoundError
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.reviews.application.dtos import (
    CreateReviewInput,
    ReviewAuthorOutput,
    ReviewCriterionOutput,
    ReviewOutput,
)
from src.modules.reviews.domain.entities.review import CriterionReview, Review
from src.modules.reviews.domain.ports.review_repository import ReviewRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class CreateReview:
    """Create a review for an existing place."""

    def __init__(
        self,
        review_repository: ReviewRepository,
        place_repository: PlaceRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._review_repository = review_repository
        self._place_repository = place_repository
        self._profile_repository = profile_repository

    def execute(self, place_id: str, author_user_id: str, payload: CreateReviewInput) -> ReviewOutput:
        place = self._place_repository.find_by_id(place_id)
        if place is None:
            raise PlaceNotFoundError("Place not found.")

        review = Review(
            id=uuid4(),
            place_id=place_id,
            author_user_id=author_user_id,
            recommendation=payload.recommendation,
            cost_benefit_rating=payload.cost_benefit_rating,
            criteria=tuple(
                CriterionReview(
                    code=item.code,
                    rating=item.rating,
                    comment=item.comment,
                    justification=item.justification,
                )
                for item in payload.criteria
            ),
            created_at=datetime.now(UTC),
            updated_at=datetime.now(UTC),
        )
        persisted = self._review_repository.save(review)
        profile = self._profile_repository.find_by_user_id(author_user_id)

        return ReviewOutput(
            id=str(persisted.id),
            place_id=persisted.place_id,
            user=ReviewAuthorOutput(
                id=persisted.author_user_id,
                name=None if profile is None else profile.name,
            ),
            recommendation=persisted.recommendation,
            cost_benefit_rating=persisted.cost_benefit_rating,
            criteria=[
                ReviewCriterionOutput(
                    code=criterion.code,
                    rating=criterion.rating,
                    comment=criterion.comment,
                    justification=criterion.justification,
                )
                for criterion in persisted.criteria
            ],
            created_at=persisted.created_at,
        )
