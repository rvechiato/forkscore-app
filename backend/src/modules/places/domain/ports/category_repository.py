from typing import Protocol

from src.modules.places.domain.entities.category import Category


class CategoryRepository(Protocol):
    """Port for place category reads."""

    def list_active(self) -> list[Category]:
        """Return active categories available for selection."""

    def find_active_by_id(self, category_id: str) -> Category | None:
        """Return an active category by id if it exists."""
