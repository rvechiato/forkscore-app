from typing import Protocol

from src.modules.places.domain.entities.place import Place


class PlaceRepository(Protocol):
    """Port for place persistence operations."""

    def save(self, place: Place) -> Place:
        """Persist and return a place."""

    def list_all(self) -> list[Place]:
        """Return all places ordered for catalog display."""

    def find_by_id(self, place_id: str) -> Place | None:
        """Return a place by identifier if it exists."""
