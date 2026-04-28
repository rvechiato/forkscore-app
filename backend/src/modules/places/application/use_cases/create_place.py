from datetime import UTC, datetime
from uuid import uuid4

from src.modules.places.application.dtos import (
    CreatePlaceInput,
    PlaceAuthorOutput,
    PlaceCategoryOutput,
    PlaceDetailOutput,
    PlaceSubcategoryOutput,
)
from src.modules.places.domain.entities.category import Category
from src.modules.places.domain.entities.place import Place
from src.modules.places.domain.entities.subcategory import Subcategory
from src.modules.places.domain.errors import (
    InvalidPlaceCategoryError,
    InvalidPlaceSubcategoryError,
)
from src.modules.places.domain.ports.category_repository import CategoryRepository
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.places.domain.ports.subcategory_repository import (
    SubcategoryRepository,
)
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class CreatePlace:
    """Create a new place linked to the authenticated user."""

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

    def execute(self, user_id: str, data: CreatePlaceInput) -> PlaceDetailOutput:
        profile = self._profile_repository.find_by_user_id(user_id)
        now = datetime.now(UTC)
        category = self._get_category(data.category_id)
        subcategory = self._get_subcategory(
            category_id=data.category_id,
            subcategory_id=data.subcategory_id,
        )

        place = Place(
            id=uuid4(),
            name=data.name,
            street=data.street,
            number=data.number,
            neighborhood=data.neighborhood,
            city=data.city,
            category_id=category.id,
            subcategory_id=subcategory.id,
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
            category_id=str(persisted_place.category_id),
            subcategory_id=str(persisted_place.subcategory_id),
            category=self._map_category(category),
            subcategory=self._map_subcategory(subcategory),
            created_by=PlaceAuthorOutput(
                id=persisted_place.created_by_user_id,
                name=None if profile is None else profile.name,
            ),
            created_at=persisted_place.created_at,
            updated_at=persisted_place.updated_at,
        )

    def _get_category(self, category_id: str) -> Category:
        category = self._category_repository.find_active_by_id(category_id)
        if category is None:
            raise InvalidPlaceCategoryError("Category not found.")
        return category

    def _get_subcategory(
        self,
        *,
        category_id: str,
        subcategory_id: str,
    ) -> Subcategory:
        subcategory = self._subcategory_repository.find_active_by_id(subcategory_id)
        if subcategory is None:
            raise InvalidPlaceSubcategoryError("Subcategory not found.")
        if str(subcategory.category_id) != category_id:
            raise InvalidPlaceSubcategoryError(
                "The provided subcategory does not belong to the selected category.",
            )
        return subcategory

    def _map_category(self, category: Category) -> PlaceCategoryOutput:
        return PlaceCategoryOutput(
            id=str(category.id),
            name=category.name,
            slug=category.slug,
        )

    def _map_subcategory(self, subcategory: Subcategory) -> PlaceSubcategoryOutput:
        return PlaceSubcategoryOutput(
            id=str(subcategory.id),
            category_id=str(subcategory.category_id),
            name=subcategory.name,
            slug=subcategory.slug,
        )
