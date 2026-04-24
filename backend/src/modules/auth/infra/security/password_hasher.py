from passlib.context import CryptContext

from src.modules.auth.domain.ports.password_hasher import PasswordHasher


class PasslibPasswordHasher(PasswordHasher):
    """Password hasher backed by passlib PBKDF2."""

    def __init__(self) -> None:
        self._context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")

    def hash_password(self, raw_password: str) -> str:
        return self._context.hash(raw_password)

    def verify_password(self, raw_password: str, hashed_password: str) -> bool:
        return self._context.verify(raw_password, hashed_password)
