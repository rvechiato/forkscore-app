from sqlalchemy.orm import Session

from fastapi import Depends

from src.app.settings import Settings, get_settings
from src.modules.auth.application.use_cases.authenticate_user import AuthenticateUser
from src.modules.auth.application.use_cases.register_user import RegisterUser
from src.modules.auth.domain.ports.password_hasher import PasswordHasher
from src.modules.auth.domain.ports.token_service import TokenService
from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.auth.infra.repositories.sqlalchemy_user_repository import (
    SqlAlchemyUserRepository,
)
from src.modules.auth.infra.security.jwt_token_service import JwtTokenService
from src.modules.auth.infra.security.password_hasher import PasslibPasswordHasher
from src.shared.infra.database.session import get_db_session


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


def get_register_user_use_case(
    user_repository: UserRepository = Depends(get_user_repository),
    password_hasher: PasswordHasher = Depends(get_password_hasher),
    token_service: TokenService = Depends(get_token_service),
) -> RegisterUser:
    """Provide the register user use case."""

    return RegisterUser(
        user_repository=user_repository,
        password_hasher=password_hasher,
        token_service=token_service,
    )


def get_authenticate_user_use_case(
    user_repository: UserRepository = Depends(get_user_repository),
    password_hasher: PasswordHasher = Depends(get_password_hasher),
    token_service: TokenService = Depends(get_token_service),
) -> AuthenticateUser:
    """Provide the login use case."""

    return AuthenticateUser(
        user_repository=user_repository,
        password_hasher=password_hasher,
        token_service=token_service,
    )
