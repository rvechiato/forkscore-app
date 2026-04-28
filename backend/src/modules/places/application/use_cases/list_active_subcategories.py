from src.modules.places.application.dtos import PlaceSubcategoryOutput
from src.modules.places.domain.errors import InvalidPlaceCategoryError
from src.modules.places.domain.ports.category_repository import CategoryRepository
from src.modules.places.domain.ports.subcategory_repository import (
    SubcategoryRepository,
)


class ListActiveSubcategories:
    """List active subcategories scoped to a category."""

    def __init__(
        self,
        category_repository: CategoryRepository,
        subcategory_repository: SubcategoryRepository,
    ) -> None:
        self._category_repository = category_repository
        self._subcategory_repository = subcategory_repository

    def execute(self, category_id: str) -> list[PlaceSubcategoryOutput]:
        category = self._category_repository.find_active_by_id(category_id)
        if category is None:
            raise InvalidPlaceCategoryError("Category not found.")

        subcategories = self._subcategory_repository.list_active_by_category(
            category_id,
        )
        return [
            PlaceSubcategoryOutput(
                id=str(subcategory.id),
                category_id=str(subcategory.category_id),
                name=subcategory.name,
                slug=subcategory.slug,
            )
            for subcategory in subcategories
        ]
