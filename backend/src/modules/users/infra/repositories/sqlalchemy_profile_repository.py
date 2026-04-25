from sqlalchemy import select
from sqlalchemy.orm import Session

from src.modules.users.domain.entities.profile import Profile
from src.modules.users.domain.ports.profile_repository import ProfileRepository
from src.modules.users.infra.database.models import ProfileModel


class SqlAlchemyProfileRepository(ProfileRepository):
    """Profile repository backed by SQLAlchemy and SQLite."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def save(self, profile: Profile) -> Profile:
        model = ProfileModel(
            user_id=str(profile.user_id),
            name=profile.name,
            birth_date=profile.birth_date,
            created_at=profile.created_at,
            updated_at=profile.updated_at,
        )
        self._session.add(model)
        self._session.commit()
        self._session.refresh(model)
        return model.to_entity()

    def find_by_user_id(self, user_id: str) -> Profile | None:
        statement = select(ProfileModel).where(ProfileModel.user_id == user_id)
        model = self._session.execute(statement).scalar_one_or_none()
        if model is None:
            return None
        return model.to_entity()

    def update(self, profile: Profile) -> Profile:
        model = self._session.get(ProfileModel, str(profile.user_id))
        if model is None:
            raise ValueError("Profile not found.")

        model.name = profile.name
        model.birth_date = profile.birth_date
        model.updated_at = profile.updated_at
        self._session.add(model)
        self._session.commit()
        self._session.refresh(model)
        return model.to_entity()
