from fastapi import Depends

from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.auth.presentation.api.dependencies import (
    get_profile_repository,
    get_user_repository,
)
from src.modules.users.application.use_cases.get_my_profile import GetMyProfile
from src.modules.users.application.use_cases.update_my_profile import UpdateMyProfile
from src.modules.users.domain.ports.profile_repository import ProfileRepository


def get_my_profile_use_case(
    user_repository: UserRepository = Depends(get_user_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> GetMyProfile:
    """Provide the get-my-profile use case."""

    return GetMyProfile(
        user_repository=user_repository,
        profile_repository=profile_repository,
    )


def get_update_my_profile_use_case(
    user_repository: UserRepository = Depends(get_user_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> UpdateMyProfile:
    """Provide the update-my-profile use case."""

    return UpdateMyProfile(
        user_repository=user_repository,
        profile_repository=profile_repository,
    )
