from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.shared.infra.database.base import Base

if TYPE_CHECKING:
    from src.modules.reviews.domain.entities.review import CriterionReview, Review


class ReviewCriterionModel(Base):
    """SQLAlchemy model for persisted review criteria."""

    __tablename__ = "review_criteria"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    review_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("reviews.id", ondelete="CASCADE"),
        nullable=False,
    )
    position: Mapped[int] = mapped_column(Integer, nullable=False)
    code: Mapped[str] = mapped_column(String(32), nullable=False)
    rating: Mapped[int] = mapped_column(Integer, nullable=False)
    comment: Mapped[str] = mapped_column(String(500), nullable=False)
    justification: Mapped[str | None] = mapped_column(String(500), nullable=True)

    def to_entity(self) -> CriterionReview:
        """Map ORM model to domain criterion entity."""

        from src.modules.reviews.domain.entities.review import CriterionReview

        return CriterionReview(
            code=self.code,
            rating=self.rating,
            comment=self.comment,
            justification=self.justification,
        )


class ReviewModel(Base):
    """SQLAlchemy model for reviews."""

    __tablename__ = "reviews"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    place_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("places.id", ondelete="CASCADE"),
        nullable=False,
    )
    author_user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    recommendation: Mapped[str] = mapped_column(String(32), nullable=False)
    cost_benefit_rating: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    criteria: Mapped[list[ReviewCriterionModel]] = relationship(
        cascade="all, delete-orphan",
        order_by="ReviewCriterionModel.position",
    )

    def to_entity(self) -> Review:
        """Map ORM model to domain review entity."""

        from src.modules.reviews.domain.entities.review import Review

        return Review(
            id=UUID(self.id),
            place_id=self.place_id,
            author_user_id=self.author_user_id,
            recommendation=self.recommendation,
            cost_benefit_rating=self.cost_benefit_rating,
            criteria=tuple(criterion.to_entity() for criterion in self.criteria),
            created_at=self.created_at,
            updated_at=self.updated_at,
        )
