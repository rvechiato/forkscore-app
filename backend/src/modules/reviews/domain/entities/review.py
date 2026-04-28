from dataclasses import dataclass
from datetime import datetime
from uuid import UUID

from src.modules.reviews.domain.errors import ReviewValidationError


ALLOWED_RECOMMENDATIONS = {"recommended", "not_recommended"}
REQUIRED_CRITERIA_CODES = ("taste", "service", "options", "infrastructure")


@dataclass(frozen=True)
class CriterionReview:
    """Single criterion evaluation inside a review."""

    code: str
    rating: int
    comment: str
    justification: str | None = None

    def __post_init__(self) -> None:
        if self.code not in REQUIRED_CRITERIA_CODES:
            raise ReviewValidationError("Criterion code is invalid.")
        if not 1 <= self.rating <= 5:
            raise ReviewValidationError("Criterion rating must be between 1 and 5.")

        normalized_comment = self.comment.strip()
        if not normalized_comment:
            raise ReviewValidationError("Criterion comment is required.")
        object.__setattr__(self, "comment", normalized_comment)

        if self.justification is None:
            if self.rating < 3:
                raise ReviewValidationError(
                    "Criterion justification is required when rating is below 3."
                )
            return

        normalized_justification = self.justification.strip()
        if not normalized_justification:
            raise ReviewValidationError("Criterion justification cannot be blank.")
        if self.rating >= 3:
            object.__setattr__(self, "justification", normalized_justification)
            return

        object.__setattr__(self, "justification", normalized_justification)


@dataclass(frozen=True)
class Review:
    """Review aggregate root for the MVP."""

    id: UUID
    place_id: str
    author_user_id: str
    recommendation: str
    cost_benefit_rating: int
    criteria: tuple[CriterionReview, ...]
    created_at: datetime
    updated_at: datetime

    def __post_init__(self) -> None:
        if self.recommendation not in ALLOWED_RECOMMENDATIONS:
            raise ReviewValidationError("Recommendation value is invalid.")
        if not 1 <= self.cost_benefit_rating <= 5:
            raise ReviewValidationError("Cost benefit rating must be between 1 and 5.")
        if len(self.criteria) != len(REQUIRED_CRITERIA_CODES):
            raise ReviewValidationError("A review must contain exactly four criteria.")

        received_codes = tuple(criterion.code for criterion in self.criteria)
        if set(received_codes) != set(REQUIRED_CRITERIA_CODES):
            raise ReviewValidationError("A review must contain all four required criteria.")
        if len(set(received_codes)) != len(REQUIRED_CRITERIA_CODES):
            raise ReviewValidationError("A review cannot repeat criteria.")
