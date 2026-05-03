from __future__ import annotations

from typing import TYPE_CHECKING
from datetime import datetime
from uuid import UUID

from sqlalchemy import Boolean, DateTime, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from src.shared.infra.database.base import Base

if TYPE_CHECKING:
    from src.modules.places.domain.entities.category import Category
    from src.modules.places.domain.entities.place import Place
    from src.modules.places.domain.entities.subcategory import Subcategory


class CategoryModel(Base):
    """SQLAlchemy model for top-level place categories."""

    __tablename__ = "categories"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    slug: Mapped[str] = mapped_column(String(80), nullable=False, unique=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    def to_entity(self) -> Category:
        from src.modules.places.domain.entities.category import Category

        return Category(
            id=UUID(self.id),
            name=self.name,
            slug=self.slug,
            is_active=self.is_active,
            created_at=self.created_at,
            updated_at=self.updated_at,
        )


class SubcategoryModel(Base):
    """SQLAlchemy model for place subcategories."""

    __tablename__ = "subcategories"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    category_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("categories.id", ondelete="RESTRICT"),
        nullable=False,
    )
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    slug: Mapped[str] = mapped_column(String(80), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    def to_entity(self) -> Subcategory:
        from src.modules.places.domain.entities.subcategory import Subcategory

        return Subcategory(
            id=UUID(self.id),
            category_id=UUID(self.category_id),
            name=self.name,
            slug=self.slug,
            is_active=self.is_active,
            created_at=self.created_at,
            updated_at=self.updated_at,
        )


class PlaceModel(Base):
    """SQLAlchemy model for places."""

    __tablename__ = "places"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    street: Mapped[str] = mapped_column(String(120), nullable=False)
    number: Mapped[str] = mapped_column(String(20), nullable=False)
    neighborhood: Mapped[str] = mapped_column(String(80), nullable=False)
    city: Mapped[str] = mapped_column(String(80), nullable=False)
    instagram_url: Mapped[str | None] = mapped_column(String(255), nullable=True)
    category_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("categories.id", ondelete="RESTRICT"),
        nullable=False,
    )
    subcategory_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("subcategories.id", ondelete="RESTRICT"),
        nullable=False,
    )
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
            instagram_url=self.instagram_url,
            category_id=UUID(self.category_id),
            subcategory_id=UUID(self.subcategory_id),
            created_by_user_id=self.created_by_user_id,
            created_at=self.created_at,
            updated_at=self.updated_at,
        )
