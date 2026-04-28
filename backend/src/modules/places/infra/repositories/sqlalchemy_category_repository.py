from sqlalchemy import select
from sqlalchemy.orm import Session

from src.modules.places.domain.entities.category import Category
from src.modules.places.domain.ports.category_repository import CategoryRepository
from src.modules.places.infra.database.models import CategoryModel


class SqlAlchemyCategoryRepository(CategoryRepository):
    """Category repository backed by SQLAlchemy."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def list_active(self) -> list[Category]:
        statement = (
            select(CategoryModel)
            .where(CategoryModel.is_active.is_(True))
            .order_by(CategoryModel.name.asc())
        )
        models = self._session.execute(statement).scalars().all()
        return [model.to_entity() for model in models]

    def find_active_by_id(self, category_id: str) -> Category | None:
        statement = select(CategoryModel).where(
            CategoryModel.id == category_id,
            CategoryModel.is_active.is_(True),
        )
        model = self._session.execute(statement).scalar_one_or_none()
        return None if model is None else model.to_entity()
