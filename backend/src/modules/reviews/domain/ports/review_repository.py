from dataclasses import dataclass
from typing import Protocol

from src.modules.reviews.domain.entities.review import Review


@dataclass(frozen=True)
class PlaceReviewSummary:
    """Compact review summary for place list rows."""

    total_reviews: int
    average_rating: float | None


class ReviewRepository(Protocol):
    """Port for review persistence."""

    def save(self, review: Review) -> Review:
        """Persist and return a review."""

    def list_by_place_id(self, place_id: str) -> list[Review]:
        """Return reviews for a place ordered from newest to oldest."""

    def summaries_by_place_ids(self, place_ids: list[str]) -> dict[str, PlaceReviewSummary]:
        """Return compact review summaries grouped by place id."""
