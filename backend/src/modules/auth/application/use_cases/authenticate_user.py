from src.modules.auth.application.dtos import (
    AuthSuccessOutput,
    AuthenticatedUserOutput,
    LoginInput,
)
from src.modules.auth.domain.errors import InvalidCredentialsError
from src.modules.auth.domain.ports.password_hasher import PasswordHasher
from src.modules.auth.domain.ports.token_service import TokenService
from src.modules.auth.domain.ports.user_repository import UserRepository


class AuthenticateUser:
    """Authenticate a user and emit an access token."""

    def __init__(
        self,
        user_repository: UserRepository,
        password_hasher: PasswordHasher,
        token_service: TokenService,
    ) -> None:
        self._user_repository = user_repository
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

        access_token = self._token_service.create_access_token(subject=str(user.id))
        return AuthSuccessOutput(
            access_token=access_token,
            user=AuthenticatedUserOutput(
                id=str(user.id),
                name=user.name,
                email=user.email,
            ),
        )
