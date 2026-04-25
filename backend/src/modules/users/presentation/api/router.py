from fastapi import APIRouter, Depends, HTTPException, status

from src.modules.auth.domain.entities.user import User
from src.modules.auth.presentation.api.dependencies import get_current_user
from src.modules.users.application.dtos import MyProfileOutput, UpdateMyProfileInput
from src.modules.users.application.use_cases.get_my_profile import GetMyProfile
from src.modules.users.application.use_cases.update_my_profile import UpdateMyProfile
from src.modules.users.domain.errors import EmailAlreadyInUseError, ProfileNotFoundError
from src.modules.users.presentation.api.dependencies import (
    get_my_profile_use_case,
    get_update_my_profile_use_case,
)


router = APIRouter(tags=["users"])


@router.get(
    "/me",
    response_model=MyProfileOutput,
    status_code=status.HTTP_200_OK,
    summary="Consultar meu perfil",
)
def get_my_profile(
    current_user: User = Depends(get_current_user),
    use_case: GetMyProfile = Depends(get_my_profile_use_case),
) -> MyProfileOutput:
    """Return the authenticated profile."""

    try:
        return use_case.execute(str(current_user.id))
    except ProfileNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc


@router.put(
    "/me",
    response_model=MyProfileOutput,
    status_code=status.HTTP_200_OK,
    summary="Atualizar meu perfil",
)
def update_my_profile(
    payload: UpdateMyProfileInput,
    current_user: User = Depends(get_current_user),
    use_case: UpdateMyProfile = Depends(get_update_my_profile_use_case),
) -> MyProfileOutput:
    """Update the authenticated profile."""

    try:
        return use_case.execute(str(current_user.id), payload)
    except ProfileNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc
    except EmailAlreadyInUseError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(exc),
        ) from exc
