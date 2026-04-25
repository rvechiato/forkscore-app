from __future__ import annotations

from typing import TYPE_CHECKING
from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from src.shared.infra.database.base import Base

if TYPE_CHECKING:
    from src.modules.places.domain.entities.place import Place


class PlaceModel(Base):
    """SQLAlchemy model for places."""

    __tablename__ = "places"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    street: Mapped[str] = mapped_column(String(120), nullable=False)
    number: Mapped[str] = mapped_column(String(20), nullable=False)
    neighborhood: Mapped[str] = mapped_column(String(80), nullable=False)
    city: Mapped[str] = mapped_column(String(80), nullable=False)
    created_by_user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    def to_entity(self) -> Place:
        """Map ORM model to domain entity."""

        from src.modules.places.domain.entities.place import Place

        return Place(
            id=UUID(self.id),
            name=self.name,
            street=self.street,
            number=self.number,
            neighborhood=self.neighborhood,
            city=self.city,
            created_by_user_id=self.created_by_user_id,
            created_at=self.created_at,
            updated_at=self.updated_at,
        )
