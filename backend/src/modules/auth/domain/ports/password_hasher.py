from typing import Protocol


class PasswordHasher(Protocol):
    """Port for password hashing implementations."""

    def hash_password(self, raw_password: str) -> str:
        """Return a secure hash for the provided password."""

    def verify_password(self, raw_password: str, hashed_password: str) -> bool:
        """Validate a raw password against a persisted hash."""

