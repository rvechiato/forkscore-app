from typing import TYPE_CHECKING
from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import DateTime, String
from sqlalchemy.orm import Mapped, mapped_column

from src.shared.infra.database.base import Base

if TYPE_CHECKING:
    from src.modules.auth.domain.entities.user import User


class UserModel(Base):
    """SQLAlchemy model for authenticated users."""

    __tablename__ = "users"

    id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid4()),
    )
    email: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    def to_entity(self) -> User:
        """Map ORM model to domain entity."""

        from src.modules.auth.domain.entities.user import User

        return User(
            id=UUID(self.id),
            email=self.email,
            password_hash=self.password_hash,
            created_at=self.created_at,
        )
