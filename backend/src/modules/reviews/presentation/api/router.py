from fastapi import APIRouter, Depends, HTTPException, status

from src.modules.auth.domain.entities.user import User
from src.modules.auth.presentation.api.dependencies import get_current_user
from src.modules.places.domain.errors import PlaceNotFoundError
from src.modules.reviews.application.dtos import CreateReviewInput, ReviewOutput
from src.modules.reviews.application.use_cases.create_review import CreateReview
from src.modules.reviews.domain.errors import ReviewValidationError
from src.modules.reviews.presentation.api.dependencies import (
    get_create_review_use_case,
)


router = APIRouter(prefix="/places", tags=["reviews"])


@router.post(
    "/{place_id}/reviews",
    response_model=ReviewOutput,
    status_code=status.HTTP_201_CREATED,
    summary="Criar avaliacao de local",
)
def create_review(
    place_id: str,
    payload: CreateReviewInput,
    current_user: User = Depends(get_current_user),
    use_case: CreateReview = Depends(get_create_review_use_case),
) -> ReviewOutput:
    """Create a review for the selected place."""

    try:
        return use_case.execute(place_id, str(current_user.id), payload)
    except PlaceNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc
    except ReviewValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        ) from exc
