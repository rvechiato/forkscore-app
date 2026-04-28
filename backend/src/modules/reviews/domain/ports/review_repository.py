from typing import Protocol

from src.modules.reviews.domain.entities.review import Review


class ReviewRepository(Protocol):
    """Port for review persistence."""

    def save(self, review: Review) -> Review:
        """Persist and return a review."""
