from datetime import UTC, datetime, timedelta

from jose import JWTError, jwt

from src.app.settings import Settings
from src.modules.auth.domain.errors import InvalidAccessTokenError
from src.modules.auth.domain.ports.token_service import TokenService


class JwtTokenService(TokenService):
    """JWT access token generator."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    def create_access_token(self, subject: str) -> str:
        expires_at = datetime.now(UTC) + timedelta(
            minutes=self._settings.jwt_expires_in_minutes
        )
        payload = {
            "sub": subject,
            "exp": expires_at,
        }
        return jwt.encode(
            payload,
            self._settings.jwt_secret_key,
            algorithm=self._settings.jwt_algorithm,
        )

    def get_subject(self, token: str) -> str:
        try:
            payload = jwt.decode(
                token,
                self._settings.jwt_secret_key,
                algorithms=[self._settings.jwt_algorithm],
            )
        except JWTError as exc:
            raise InvalidAccessTokenError("Invalid access token.") from exc

        subject = payload.get("sub")
        if not isinstance(subject, str) or not subject:
            raise InvalidAccessTokenError("Invalid access token.")

        return subject
