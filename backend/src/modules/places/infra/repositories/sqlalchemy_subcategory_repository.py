from sqlalchemy import select
from sqlalchemy.orm import Session

from src.modules.places.domain.entities.subcategory import Subcategory
from src.modules.places.domain.ports.subcategory_repository import (
    SubcategoryRepository,
)
from src.modules.places.infra.database.models import SubcategoryModel


class SqlAlchemySubcategoryRepository(SubcategoryRepository):
    """Subcategory repository backed by SQLAlchemy."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def list_active_by_category(self, category_id: str) -> list[Subcategory]:
        statement = (
            select(SubcategoryModel)
            .where(
                SubcategoryModel.category_id == category_id,
                SubcategoryModel.is_active.is_(True),
            )
            .order_by(SubcategoryModel.name.asc())
        )
        models = self._session.execute(statement).scalars().all()
        return [model.to_entity() for model in models]

    def find_active_by_id(self, subcategory_id: str) -> Subcategory | None:
        statement = select(SubcategoryModel).where(
            SubcategoryModel.id == subcategory_id,
            SubcategoryModel.is_active.is_(True),
        )
        model = self._session.execute(statement).scalar_one_or_none()
        return None if model is None else model.to_entity()
