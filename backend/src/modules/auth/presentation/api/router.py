from fastapi import APIRouter, Depends, HTTPException, status

from src.modules.auth.application.dtos import (
    AuthSuccessOutput,
    LoginInput,
    RegisterUserInput,
)
from src.modules.auth.application.use_cases.authenticate_user import AuthenticateUser
from src.modules.auth.application.use_cases.register_user import RegisterUser
from src.modules.auth.domain.errors import InvalidCredentialsError, UserAlreadyExistsError
from src.modules.auth.presentation.api.dependencies import (
    get_authenticate_user_use_case,
    get_register_user_use_case,
)


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/register",
    response_model=AuthSuccessOutput,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar novo usuário",
)
def register_user(
    payload: RegisterUserInput,
    use_case: RegisterUser = Depends(get_register_user_use_case),
) -> AuthSuccessOutput:
    """Register a new user and return an access token."""

    try:
        return use_case.execute(payload)
    except UserAlreadyExistsError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(exc),
        ) from exc


@router.post(
    "/login",
    response_model=AuthSuccessOutput,
    status_code=status.HTTP_200_OK,
    summary="Autenticar usuário",
)
def login(
    payload: LoginInput,
    use_case: AuthenticateUser = Depends(get_authenticate_user_use_case),
) -> AuthSuccessOutput:
    """Authenticate a user and return an access token."""

    try:
        return use_case.execute(payload)
    except InvalidCredentialsError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc),
        ) from exc
