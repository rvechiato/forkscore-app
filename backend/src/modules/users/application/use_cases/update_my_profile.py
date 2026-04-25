from dataclasses import replace
from datetime import UTC, datetime

from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.users.application.dtos import MyProfileOutput, UpdateMyProfileInput
from src.modules.users.application.use_cases.get_my_profile import _calculate_age
from src.modules.users.domain.entities.profile import Profile
from src.modules.users.domain.errors import EmailAlreadyInUseError, ProfileNotFoundError
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class UpdateMyProfile:
    """Update the authenticated user profile and canonical email."""

    def __init__(
        self,
        user_repository: UserRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._user_repository = user_repository
        self._profile_repository = profile_repository

    def execute(self, user_id: str, data: UpdateMyProfileInput) -> MyProfileOutput:
        user = self._user_repository.find_by_id(user_id)
        profile = self._profile_repository.find_by_user_id(user_id)

        if user is None or profile is None:
            raise ProfileNotFoundError("Profile not found.")

        existing_user = self._user_repository.find_by_email(data.email)
        if existing_user is not None and str(existing_user.id) != user_id:
            raise EmailAlreadyInUseError("A user with this email already exists.")

        updated_user = self._user_repository.update(
            replace(user, email=data.email)
        )
        updated_profile = self._profile_repository.update(
            Profile(
                user_id=profile.user_id,
                name=data.name,
                birth_date=data.birth_date,
                created_at=profile.created_at,
                updated_at=datetime.now(UTC),
            )
        )

        return MyProfileOutput(
            id=str(updated_user.id),
            name=updated_profile.name,
            birth_date=updated_profile.birth_date,
            age=_calculate_age(updated_profile.birth_date),
            email=updated_user.email,
        )
