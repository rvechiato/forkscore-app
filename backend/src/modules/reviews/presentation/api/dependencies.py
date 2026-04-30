from fastapi import Depends
from sqlalchemy.orm import Session

from src.modules.auth.presentation.api.dependencies import get_profile_repository
from src.modules.places.presentation.api.dependencies import get_place_repository
from src.modules.reviews.application.use_cases.create_review import CreateReview
from src.modules.reviews.application.use_cases.get_place_reviews_summary import (
    GetPlaceReviewsSummary,
)
from src.modules.reviews.application.use_cases.list_place_reviews import (
    ListPlaceReviews,
)
from src.modules.reviews.domain.ports.review_repository import ReviewRepository
from src.modules.reviews.infra.repositories.sqlalchemy_review_repository import (
    SqlAlchemyReviewRepository,
)
from src.modules.users.domain.ports.profile_repository import ProfileRepository
from src.shared.infra.database.session import get_db_session


def get_review_repository(
    session: Session = Depends(get_db_session),
) -> ReviewRepository:
    """Provide a review repository backed by the current database session."""

    return SqlAlchemyReviewRepository(session=session)


def get_create_review_use_case(
    review_repository: ReviewRepository = Depends(get_review_repository),
    place_repository=Depends(get_place_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> CreateReview:
    """Provide the create review use case."""

    return CreateReview(
        review_repository=review_repository,
        place_repository=place_repository,
        profile_repository=profile_repository,
    )


def get_place_reviews_summary_use_case(
    review_repository: ReviewRepository = Depends(get_review_repository),
    place_repository=Depends(get_place_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> GetPlaceReviewsSummary:
    """Provide the place review summary use case."""

    return GetPlaceReviewsSummary(
        review_repository=review_repository,
        place_repository=place_repository,
        profile_repository=profile_repository,
    )


def get_list_place_reviews_use_case(
    review_repository: ReviewRepository = Depends(get_review_repository),
    place_repository=Depends(get_place_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> ListPlaceReviews:
    """Provide the place reviews listing use case."""

    return ListPlaceReviews(
        review_repository=review_repository,
        place_repository=place_repository,
        profile_repository=profile_repository,
    )
