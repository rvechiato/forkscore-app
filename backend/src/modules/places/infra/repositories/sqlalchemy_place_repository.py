from sqlalchemy import select
from sqlalchemy.orm import Session

from src.modules.places.domain.entities.place import Place
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.places.infra.database.models import PlaceModel


class SqlAlchemyPlaceRepository(PlaceRepository):
    """Place repository backed by SQLAlchemy and SQLite."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def save(self, place: Place) -> Place:
        model = PlaceModel(
            id=str(place.id),
            name=place.name,
            street=place.street,
            number=place.number,
            neighborhood=place.neighborhood,
            city=place.city,
            created_by_user_id=place.created_by_user_id,
            created_at=place.created_at,
            updated_at=place.updated_at,
        )
        self._session.add(model)
        self._session.commit()
        self._session.refresh(model)
        return model.to_entity()

    def list_all(self) -> list[Place]:
        statement = select(PlaceModel).order_by(PlaceModel.created_at.desc())
        models = self._session.execute(statement).scalars().all()
        return [model.to_entity() for model in models]

    def find_by_id(self, place_id: str) -> Place | None:
        model = self._session.get(PlaceModel, place_id)
        if model is None:
            return None
        return model.to_entity()
