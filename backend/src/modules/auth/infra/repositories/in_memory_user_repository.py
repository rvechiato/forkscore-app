from collections.abc import Iterable

from src.modules.auth.domain.entities.user import User
from src.modules.auth.domain.ports.user_repository import UserRepository


class InMemoryUserRepository(UserRepository):
    """Temporary repository used while SQLite persistence is not implemented."""

    def __init__(self, users: Iterable[User] | None = None) -> None:
        self._users_by_email = {user.email: user for user in users or []}
        self._users_by_id = {str(user.id): user for user in users or []}

    def exists_by_email(self, email: str) -> bool:
        return email in self._users_by_email

    def save(self, user: User) -> User:
        self._users_by_email[user.email] = user
        self._users_by_id[str(user.id)] = user
        return user

    def find_by_email(self, email: str) -> User | None:
        return self._users_by_email.get(email)

    def find_by_id(self, user_id: str) -> User | None:
        return self._users_by_id.get(user_id)

    def update(self, user: User) -> User:
        for email, existing_user in list(self._users_by_email.items()):
            if str(existing_user.id) == str(user.id) and email != user.email:
                del self._users_by_email[email]

        self._users_by_email[user.email] = user
        self._users_by_id[str(user.id)] = user
        return user
