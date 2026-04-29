from src.modules.places.domain.errors import PlaceNotFoundError
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.reviews.application.dtos import (
    PlaceReviewsSummaryOutput,
    RecentReviewOutput,
    ReviewAuthorOutput,
    ReviewCriterionOutput,
)
from src.modules.reviews.domain.ports.review_repository import ReviewRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class GetPlaceReviewsSummary:
    """Return the MVP review summary shown in the place detail."""

    def __init__(
        self,
        review_repository: ReviewRepository,
        place_repository: PlaceRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._review_repository = review_repository
        self._place_repository = place_repository
        self._profile_repository = profile_repository

    def execute(self, place_id: str) -> PlaceReviewsSummaryOutput:
        place = self._place_repository.find_by_id(place_id)
        if place is None:
            raise PlaceNotFoundError("Place not found.")

        reviews = self._review_repository.list_by_place_id(place_id)
        total_reviews = len(reviews)
        average_rating = None
        if total_reviews > 0:
            average_rating = round(
                sum(review.overall_rating for review in reviews) / total_reviews,
                2,
            )

        recent_reviews = []
        for review in reviews[:3]:
            profile = self._profile_repository.find_by_user_id(review.author_user_id)
            recent_reviews.append(
                RecentReviewOutput(
                    id=str(review.id),
                    user=ReviewAuthorOutput(
                        id=review.author_user_id,
                        name=None if profile is None else profile.name,
                    ),
                    recommendation=review.recommendation,
                    overall_rating=review.overall_rating,
                    criteria=[
                        ReviewCriterionOutput(
                            code=criterion.code,
                            rating=criterion.rating,
                            comment=criterion.comment,
                            justification=criterion.justification,
                        )
                        for criterion in review.criteria
                    ],
                    created_at=review.created_at,
                )
            )

        return PlaceReviewsSummaryOutput(
            place_id=place_id,
            total_reviews=total_reviews,
            average_rating=average_rating,
            recent_reviews=recent_reviews,
        )
