from src.modules.places.application.dtos import (
    PlaceAuthorOutput,
    PlaceCategoryOutput,
    PlaceSubcategoryOutput,
    PlaceSummaryOutput,
)
from src.modules.places.domain.ports.category_repository import CategoryRepository
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.places.domain.ports.subcategory_repository import (
    SubcategoryRepository,
)
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class ListPlaces:
    """List the places available in the MVP catalog."""

    def __init__(
        self,
        place_repository: PlaceRepository,
        category_repository: CategoryRepository,
        subcategory_repository: SubcategoryRepository,
        profile_repository: ProfileRepository,
    ) -> None:
        self._place_repository = place_repository
        self._category_repository = category_repository
        self._subcategory_repository = subcategory_repository
        self._profile_repository = profile_repository

    def execute(self) -> list[PlaceSummaryOutput]:
        places = self._place_repository.list_all()
        results: list[PlaceSummaryOutput] = []

        for place in places:
            profile = self._profile_repository.find_by_user_id(place.created_by_user_id)
            category = self._category_repository.find_active_by_id(str(place.category_id))
            subcategory = self._subcategory_repository.find_active_by_id(
                str(place.subcategory_id),
            )
            results.append(
                PlaceSummaryOutput(
                    id=str(place.id),
                    name=place.name,
                    neighborhood=place.neighborhood,
                    city=place.city,
                    category_id=str(place.category_id),
                    subcategory_id=str(place.subcategory_id),
                    category=PlaceCategoryOutput(
                        id=str(place.category_id),
                        name="" if category is None else category.name,
                        slug="" if category is None else category.slug,
                    ),
                    subcategory=PlaceSubcategoryOutput(
                        id=str(place.subcategory_id),
                        category_id=str(place.category_id),
                        name="" if subcategory is None else subcategory.name,
                        slug="" if subcategory is None else subcategory.slug,
                    ),
                    created_by=PlaceAuthorOutput(
                        id=place.created_by_user_id,
                        name=None if profile is None else profile.name,
                    ),
                )
            )

        return results
