from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from src.modules.auth.domain.entities.user import User
from src.modules.auth.domain.errors import UserAlreadyExistsError
from src.modules.auth.domain.ports.user_repository import UserRepository
from src.modules.auth.infra.database.models import UserModel


class SqlAlchemyUserRepository(UserRepository):
    """User repository backed by SQLAlchemy and SQLite."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def exists_by_email(self, email: str) -> bool:
        statement = select(UserModel.id).where(UserModel.email == email)
        return self._session.execute(statement).scalar_one_or_none() is not None

    def save(self, user: User) -> User:
        model = UserModel(
            id=str(user.id),
            name=user.name,
            email=user.email,
            password_hash=user.password_hash,
            created_at=user.created_at,
        )
        self._session.add(model)
        try:
            self._session.commit()
        except IntegrityError as exc:
            self._session.rollback()
            raise UserAlreadyExistsError(
                "A user with this email already exists."
            ) from exc
        self._session.refresh(model)
        return model.to_entity()

    def find_by_email(self, email: str) -> User | None:
        statement = select(UserModel).where(UserModel.email == email)
        model = self._session.execute(statement).scalar_one_or_none()
        if model is None:
            return None
        return model.to_entity()

