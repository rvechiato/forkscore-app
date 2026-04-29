from typing import Protocol

from src.modules.reviews.domain.entities.review import Review


class ReviewRepository(Protocol):
    """Port for review persistence."""

    def save(self, review: Review) -> Review:
        """Persist and return a review."""

    def list_by_place_id(self, place_id: str) -> list[Review]:
        """Return reviews for a place ordered from newest to oldest."""
