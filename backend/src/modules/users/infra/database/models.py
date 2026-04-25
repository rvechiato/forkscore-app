from typing import TYPE_CHECKING
from datetime import date, datetime
from uuid import UUID

from sqlalchemy import Date, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from src.shared.infra.database.base import Base

if TYPE_CHECKING:
    from src.modules.users.domain.entities.profile import Profile


class ProfileModel(Base):
    """SQLAlchemy model for basic user profiles."""

    __tablename__ = "profiles"

    user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    birth_date: Mapped[date] = mapped_column(Date, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    def to_entity(self) -> Profile:
        """Map ORM model to domain entity."""

        from src.modules.users.domain.entities.profile import Profile

        return Profile(
            user_id=UUID(self.user_id),
            name=self.name,
            birth_date=self.birth_date,
            created_at=self.created_at,
            updated_at=self.updated_at,
        )
