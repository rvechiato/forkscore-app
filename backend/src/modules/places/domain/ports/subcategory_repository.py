from typing import Protocol

from src.modules.places.domain.entities.subcategory import Subcategory


class SubcategoryRepository(Protocol):
    """Port for place subcategory reads and validation."""

    def list_active_by_category(self, category_id: str) -> list[Subcategory]:
        """Return active subcategories for a given category."""

    def find_active_by_id(self, subcategory_id: str) -> Subcategory | None:
        """Return an active subcategory by id if it exists."""
