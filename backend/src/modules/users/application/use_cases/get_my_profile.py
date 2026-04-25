from datetime import UTC, date, datetime
from typing import Optional

from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.users.application.dtos import MyProfileOutput
from src.modules.users.domain.errors import ProfileNotFoundError
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class GetMyProfile:
    """Return the profile linked to the authenticated user."""

    def __init__(
        self,
        user_repository: UserRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._user_repository = user_repository
        self._profile_repository = profile_repository

    def execute(self, user_id: str) -> MyProfileOutput:
        user = self._user_repository.find_by_id(user_id)
        profile = self._profile_repository.find_by_user_id(user_id)

        if user is None or profile is None:
            raise ProfileNotFoundError("Profile not found.")

        return MyProfileOutput(
            id=str(user.id),
            name=profile.name,
            birth_date=profile.birth_date,
            age=_calculate_age(profile.birth_date),
            email=user.email,
        )


def _calculate_age(birth_date: Optional[date]) -> Optional[int]:
    if birth_date is None:
        return None

    today = datetime.now(UTC).date()
    years = today.year - birth_date.year
    if (today.month, today.day) < (birth_date.month, birth_date.day):
        years -= 1
    return years
