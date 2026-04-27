from src.modules.places.application.dtos import PlaceCategoryOutput
from src.modules.places.domain.ports.category_repository import CategoryRepository


class ListActiveCategories:
    """List active categories for place classification."""

    def __init__(self, category_repository: CategoryRepository) -> None:
        self._category_repository = category_repository

    def execute(self) -> list[PlaceCategoryOutput]:
        categories = self._category_repository.list_active()
        return [
            PlaceCategoryOutput(
                id=str(category.id),
                name=category.name,
                slug=category.slug,
            )
            for category in categories
        ]
