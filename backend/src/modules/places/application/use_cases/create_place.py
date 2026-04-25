from datetime import UTC, datetime
from uuid import uuid4

from src.modules.places.application.dtos import (
    CreatePlaceInput,
    PlaceAuthorOutput,
    PlaceDetailOutput,
)
from src.modules.places.domain.entities.place import Place
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class CreatePlace:
    """Create a new place linked to the authenticated user."""

    def __init__(
        self,
        place_repository: PlaceRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._place_repository = place_repository
        self._profile_repository = profile_repository

    def execute(self, user_id: str, data: CreatePlaceInput) -> PlaceDetailOutput:
        profile = self._profile_repository.find_by_user_id(user_id)
        now = datetime.now(UTC)

        place = Place(
            id=uuid4(),
            name=data.name,
            street=data.street,
            number=data.number,
            neighborhood=data.neighborhood,
            city=data.city,
            created_by_user_id=user_id,
            created_at=now,
            updated_at=now,
        )
        persisted_place = self._place_repository.save(place)

        return PlaceDetailOutput(
            id=str(persisted_place.id),
            name=persisted_place.name,
            street=persisted_place.street,
            number=persisted_place.number,
            neighborhood=persisted_place.neighborhood,
            city=persisted_place.city,
            created_by=PlaceAuthorOutput(
                id=persisted_place.created_by_user_id,
                name=None if profile is None else profile.name,
            ),
            created_at=persisted_place.created_at,
            updated_at=persisted_place.updated_at,
        )
