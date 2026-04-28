from uuid import uuid4

from sqlalchemy.orm import Session

from src.modules.reviews.domain.entities.review import Review
from src.modules.reviews.domain.ports.review_repository import ReviewRepository
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
