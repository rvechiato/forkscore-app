from datetime import UTC, date, datetime
from typing import Optional
from uuid import uuid4

from src.modules.auth.application.dtos import (
    AuthSuccessOutput,
    AuthenticatedUserOutput,
    RegisterUserInput,
)
from src.modules.auth.domain.entities.user import User
from src.modules.auth.domain.errors import UserAlreadyExistsError
from src.modules.auth.domain.ports.password_hasher import PasswordHasher
from src.modules.auth.domain.ports.token_service import TokenService
from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.users.domain.entities.profile import Profile
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class RegisterUser:
    """Register a new user in the system."""

    def __init__(
        self,
        user_repository: UserRepository,
        profile_repository: ProfileRepository,
        password_hasher: PasswordHasher,
        token_service: TokenService,
    ) -> None:
        self._user_repository = user_repository
        self._profile_repository = profile_repository
        self._password_hasher = password_hasher
        self._token_service = token_service

    def execute(self, data: RegisterUserInput) -> AuthSuccessOutput:
        """Create a new user and return an authenticated response."""

        if self._user_repository.exists_by_email(data.email):
            raise UserAlreadyExistsError("A user with this email already exists.")

        user = User(
            id=uuid4(),
            email=data.email,
            password_hash=self._password_hasher.hash_password(data.password),
            created_at=datetime.now(UTC),
        )
        persisted_user = self._user_repository.save(user)
        profile = self._profile_repository.save(
            Profile(
                user_id=persisted_user.id,
                name=data.name,
                birth_date=None,
                created_at=datetime.now(UTC),
                updated_at=datetime.now(UTC),
            )
        )
        access_token = self._token_service.create_access_token(
            subject=str(persisted_user.id)
        )
        return AuthSuccessOutput(
            access_token=access_token,
            user=AuthenticatedUserOutput(
                id=str(persisted_user.id),
                name=profile.name,
                birth_date=profile.birth_date,
                age=_calculate_age(profile.birth_date),
                email=persisted_user.email,
            ),
        )


def _calculate_age(birth_date: Optional[date]) -> Optional[int]:
    if birth_date is None:
        return None

    today = datetime.now(UTC).date()
    years = today.year - birth_date.year
    if (today.month, today.day) < (birth_date.month, birth_date.day):
        years -= 1
    return years
