from datetime import UTC, date, datetime

from src.modules.auth.application.dtos import (
    AuthSuccessOutput,
    AuthenticatedUserOutput,
    LoginInput,
)
from src.modules.auth.domain.errors import InvalidCredentialsError
from src.modules.auth.domain.ports.password_hasher import PasswordHasher
from src.modules.auth.domain.ports.token_service import TokenService
from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class AuthenticateUser:
    """Authenticate a user and emit an access token."""

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

    def execute(self, data: LoginInput) -> AuthSuccessOutput:
        """Validate credentials and return a JWT response."""

        user = self._user_repository.find_by_email(data.email)
        if user is None:
            raise InvalidCredentialsError("Invalid credentials.")

        is_valid = self._password_hasher.verify_password(
            raw_password=data.password,
            hashed_password=user.password_hash,
        )
        if not is_valid:
            raise InvalidCredentialsError("Invalid credentials.")

        profile = self._profile_repository.find_by_user_id(str(user.id))
        if profile is None:
            raise InvalidCredentialsError("Invalid credentials.")

        access_token = self._token_service.create_access_token(subject=str(user.id))
        return AuthSuccessOutput(
            access_token=access_token,
            user=AuthenticatedUserOutput(
                id=str(user.id),
                name=profile.name,
                birth_date=profile.birth_date,
                age=_calculate_age(profile.birth_date),
                email=user.email,
            ),
        )


def _calculate_age(birth_date: date) -> int:
    today = datetime.now(UTC).date()
    years = today.year - birth_date.year
    if (today.month, today.day) < (birth_date.month, birth_date.day):
        years -= 1
    return years
