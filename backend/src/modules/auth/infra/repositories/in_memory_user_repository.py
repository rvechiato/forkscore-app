from collections.abc import Iterable

from src.modules.auth.domain.entities.user import User
from src.modules.auth.domain.ports.user_repository import UserRepository


class InMemoryUserRepository(UserRepository):
    """Temporary repository used while SQLite persistence is not implemented."""

    def __init__(self, users: Iterable[User] | None = None) -> None:
        self._users = {user.email: user for user in users or []}

    def exists_by_email(self, email: str) -> bool:
        return email in self._users

    def save(self, user: User) -> User:
        self._users[user.email] = user
        return user

    def find_by_email(self, email: str) -> User | None:
        return self._users.get(email)

