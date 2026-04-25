from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from src.app.settings import Settings, get_settings
from src.modules.auth.application.use_cases.authenticate_user import AuthenticateUser
from src.modules.auth.application.use_cases.register_user import RegisterUser
from src.modules.auth.domain.entities.user import User
from src.modules.auth.domain.errors import InvalidAccessTokenError
from src.modules.auth.domain.ports.password_hasher import PasswordHasher
from src.modules.auth.domain.ports.token_service import TokenService
from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.auth.infra.repositories.sqlalchemy_user_repository import (
    SqlAlchemyUserRepository,
)
from src.modules.auth.infra.security.jwt_token_service import JwtTokenService
from src.modules.auth.infra.security.password_hasher import PasslibPasswordHasher
from src.modules.users.domain.ports.profile_repository import ProfileRepository
from src.modules.users.infra.repositories.sqlalchemy_profile_repository import (
    SqlAlchemyProfileRepository,
)
from src.shared.infra.database.session import get_db_session


bearer_scheme = HTTPBearer(auto_error=False)


def get_user_repository(
    session: Session = Depends(get_db_session),
) -> UserRepository:
    """Provide a user repository backed by the current database session."""

    return SqlAlchemyUserRepository(session=session)


def get_password_hasher() -> PasswordHasher:
    """Provide the password hashing adapter."""

    return PasslibPasswordHasher()


def get_token_service(
    settings: Settings = Depends(get_settings),
) -> TokenService:
    """Provide the JWT token adapter."""

    return JwtTokenService(settings=settings)


def get_profile_repository(
    session: Session = Depends(get_db_session),
) -> ProfileRepository:
    """Provide a profile repository backed by the current database session."""

    return SqlAlchemyProfileRepository(session=session)


def get_register_user_use_case(
    user_repository: UserRepository = Depends(get_user_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
    password_hasher: PasswordHasher = Depends(get_password_hasher),
    token_service: TokenService = Depends(get_token_service),
) -> RegisterUser:
    """Provide the register user use case."""

    return RegisterUser(
        user_repository=user_repository,
        profile_repository=profile_repository,
        password_hasher=password_hasher,
        token_service=token_service,
    )


def get_authenticate_user_use_case(
    user_repository: UserRepository = Depends(get_user_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
    password_hasher: PasswordHasher = Depends(get_password_hasher),
    token_service: TokenService = Depends(get_token_service),
) -> AuthenticateUser:
    """Provide the login use case."""

    return AuthenticateUser(
        user_repository=user_repository,
        profile_repository=profile_repository,
        password_hasher=password_hasher,
        token_service=token_service,
    )


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    token_service: TokenService = Depends(get_token_service),
    user_repository: UserRepository = Depends(get_user_repository),
) -> User:
    """Resolve the authenticated user from the bearer token."""

    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated.",
        )

    try:
        subject = token_service.get_subject(credentials.credentials)
    except InvalidAccessTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc),
        ) from exc

    user = user_repository.find_by_id(subject)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid access token.",
        )

    return user
