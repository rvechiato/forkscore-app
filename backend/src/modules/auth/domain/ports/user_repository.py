from typing import Protocol

from src.modules.auth.domain.entities.user import User


class UserRepository(Protocol):
    """Port for user persistence operations."""

    def exists_by_email(self, email: str) -> bool:
        """Return whether a user already exists with the provided email."""

    def save(self, user: User) -> User:
        """Persist and return a user."""

    def find_by_email(self, email: str) -> User | None:
        """Return a user by email if it exists."""

    def find_by_id(self, user_id: str) -> User | None:
        """Return a user by identifier if it exists."""

    def update(self, user: User) -> User:
        """Update and return a persisted user."""
