from src.modules.places.application.dtos import PlaceAuthorOutput, PlaceDetailOutput
from src.modules.places.domain.errors import PlaceNotFoundError
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class GetPlaceById:
    """Return detailed information for a specific place."""

    def __init__(
        self,
        place_repository: PlaceRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._place_repository = place_repository
        self._profile_repository = profile_repository

    def execute(self, place_id: str) -> PlaceDetailOutput:
        place = self._place_repository.find_by_id(place_id)
        if place is None:
            raise PlaceNotFoundError("Place not found.")

        profile = self._profile_repository.find_by_user_id(place.created_by_user_id)

        return PlaceDetailOutput(
            id=str(place.id),
            name=place.name,
            street=place.street,
            number=place.number,
            neighborhood=place.neighborhood,
            city=place.city,
            created_by=PlaceAuthorOutput(
                id=place.created_by_user_id,
                name=None if profile is None else profile.name,
            ),
            created_at=place.created_at,
            updated_at=place.updated_at,
        )
