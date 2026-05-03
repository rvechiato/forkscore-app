from src.modules.places.domain.errors import PlaceNotFoundError
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.reviews.application.dtos import (
    CriterionRatingOutput,
    PlaceReviewsSummaryOutput,
    RecentReviewOutput,
    RecommendationSummaryOutput,
    ReviewAuthorOutput,
    ReviewCriterionOutput,
)
from src.modules.reviews.domain.entities.review import Review
from src.modules.reviews.domain.ports.review_repository import ReviewRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class GetPlaceReviewsSummary:
    """Return the MVP review summary shown in the place detail."""

    _CRITERIA_LABELS = (
        ("taste", "Sabor"),
        ("service", "Atendimento"),
        ("options", "Opcoes"),
        ("infrastructure", "Infraestrutura"),
        ("cost_benefit", "Custo-beneficio"),
    )

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

        criteria_ratings = self._build_criteria_ratings(reviews)
        recommendation_summary = self._build_recommendation_summary(reviews)

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
            criteria_ratings=criteria_ratings,
            recommendation_summary=recommendation_summary,
            recent_reviews=recent_reviews,
        )

    def _build_criteria_ratings(
        self,
        reviews: list[Review],
    ) -> list[CriterionRatingOutput]:
        total_reviews = len(reviews)
        if total_reviews == 0:
            return [
                CriterionRatingOutput(
                    code=code,
                    label=label,
                    average_rating=None,
                    total_reviews=0,
                )
                for code, label in self._CRITERIA_LABELS
            ]

        criterion_totals = {code: 0 for code, _ in self._CRITERIA_LABELS}
        criterion_counts = {code: 0 for code, _ in self._CRITERIA_LABELS}
        for review in reviews:
            criterion_totals["cost_benefit"] += review.cost_benefit_rating
            criterion_counts["cost_benefit"] += 1
            for criterion in review.criteria:
                criterion_totals[criterion.code] += criterion.rating
                criterion_counts[criterion.code] += 1

        return [
            CriterionRatingOutput(
                code=code,
                label=label,
                average_rating=None
                if criterion_counts[code] == 0
                else round(criterion_totals[code] / criterion_counts[code], 2),
                total_reviews=criterion_counts[code],
            )
            for code, label in self._CRITERIA_LABELS
        ]

    def _build_recommendation_summary(
        self,
        reviews: list[Review],
    ) -> RecommendationSummaryOutput:
        total_reviews = len(reviews)
        recommended_count = sum(
            1 for review in reviews if review.recommendation == "recommended"
        )
        not_recommended_count = sum(
            1 for review in reviews if review.recommendation == "not_recommended"
        )

        recommended_percentage = 0
        not_recommended_percentage = 0
        if total_reviews > 0:
            recommended_percentage = int(
                (recommended_count * 100 / total_reviews) + 0.5
            )
            not_recommended_percentage = 100 - recommended_percentage

        return RecommendationSummaryOutput(
            recommended_count=recommended_count,
            not_recommended_count=not_recommended_count,
            recommended_percentage=recommended_percentage,
            not_recommended_percentage=not_recommended_percentage,
        )
