from uuid import uuid4

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from src.modules.reviews.domain.entities.review import Review
from src.modules.reviews.domain.ports.review_repository import (
    PlaceReviewSummary,
    ReviewRepository,
)
from src.modules.reviews.infra.database.models import ReviewCriterionModel, ReviewModel


class SqlAlchemyReviewRepository(ReviewRepository):
    """Review repository backed by SQLAlchemy."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def save(self, review: Review) -> Review:
        model = ReviewModel(
            id=str(review.id),
            place_id=review.place_id,
            author_user_id=review.author_user_id,
            recommendation=review.recommendation,
            cost_benefit_rating=review.cost_benefit_rating,
            overall_rating=review.overall_rating,
            created_at=review.created_at,
            updated_at=review.updated_at,
            criteria=[
                ReviewCriterionModel(
                    id=str(uuid4()),
                    position=index,
                    code=criterion.code,
                    rating=criterion.rating,
                    comment=criterion.comment,
                    justification=criterion.justification,
                )
                for index, criterion in enumerate(review.criteria)
            ],
        )
        self._session.add(model)
        self._session.commit()
        self._session.refresh(model)
        return model.to_entity()

    def list_by_place_id(self, place_id: str) -> list[Review]:
        statement = (
            select(ReviewModel)
            .where(ReviewModel.place_id == place_id)
            .order_by(ReviewModel.created_at.desc())
        )
        models = self._session.execute(statement).scalars().all()
        return [model.to_entity() for model in models]

    def summaries_by_place_ids(self, place_ids: list[str]) -> dict[str, PlaceReviewSummary]:
        if not place_ids:
            return {}

        statement = (
            select(
                ReviewModel.place_id,
                func.count(ReviewModel.id),
                func.avg(ReviewModel.overall_rating),
            )
            .where(ReviewModel.place_id.in_(place_ids))
            .group_by(ReviewModel.place_id)
        )
        rows = self._session.execute(statement).all()
        return {
            place_id: PlaceReviewSummary(
                total_reviews=total_reviews,
                average_rating=None if average_rating is None else round(average_rating, 2),
            )
            for place_id, total_reviews, average_rating in rows
        }
