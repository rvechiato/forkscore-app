from src.modules.places.application.dtos import PlaceAuthorOutput, PlaceSummaryOutput
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class ListPlaces:
    """List the places available in the MVP catalog."""

    def __init__(
        self,
        place_repository: PlaceRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._place_repository = place_repository
        self._profile_repository = profile_repository

    def execute(self) -> list[PlaceSummaryOutput]:
        places = self._place_repository.list_all()
        results: list[PlaceSummaryOutput] = []

        for place in places:
            profile = self._profile_repository.find_by_user_id(place.created_by_user_id)
            results.append(
                PlaceSummaryOutput(
                    id=str(place.id),
                    name=place.name,
                    neighborhood=place.neighborhood,
                    city=place.city,
                    created_by=PlaceAuthorOutput(
                        id=place.created_by_user_id,
                        name=None if profile is None else profile.name,
                    ),
                )
            )

        return results
