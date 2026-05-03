from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field, field_validator


ReviewCriterionCode = Literal["taste", "service", "options", "infrastructure"]
SummaryCriterionCode = Literal[
    "taste",
    "service",
    "options",
    "infrastructure",
    "cost_benefit",
]
RecommendationValue = Literal["recommended", "not_recommended"]


class ReviewCriterionInput(BaseModel):
    """Input payload for a single qualitative criterion."""

    code: ReviewCriterionCode
    rating: int = Field(ge=1, le=5)
    comment: str = Field(min_length=1, max_length=500)
    justification: str | None = Field(default=None, max_length=500)

    @field_validator("comment")
    @classmethod
    def validate_comment(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("Comment cannot be blank.")
        return normalized

    @field_validator("justification")
    @classmethod
    def validate_justification(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = value.strip()
        if not normalized:
            raise ValueError("Justification cannot be blank.")
        return normalized


class CreateReviewInput(BaseModel):
    """Input payload for creating a review."""

    recommendation: RecommendationValue
    cost_benefit_rating: int = Field(ge=1, le=5)
    criteria: list[ReviewCriterionInput] = Field(min_length=1, max_length=4)


class ReviewAuthorOutput(BaseModel):
    """Author payload for review responses."""

    id: str
    name: str | None = None


class ReviewCriterionOutput(BaseModel):
    """Read payload for a single criterion."""

    code: ReviewCriterionCode
    rating: int
    comment: str
    justification: str | None = None


class ReviewOutput(BaseModel):
    """Read payload for a created review."""

    id: str
    place_id: str
    user: ReviewAuthorOutput
    recommendation: RecommendationValue
    cost_benefit_rating: int
    criteria: list[ReviewCriterionOutput]
    created_at: datetime


class RecentReviewOutput(BaseModel):
    """Read payload for a recent review in the place detail summary."""

    id: str
    user: ReviewAuthorOutput
    recommendation: RecommendationValue
    overall_rating: float
    criteria: list[ReviewCriterionOutput]
    created_at: datetime


class CriterionRatingOutput(BaseModel):
    """Aggregated rating for a criterion in the place detail summary."""

    code: SummaryCriterionCode
    label: str
    average_rating: float | None
    total_reviews: int


class RecommendationSummaryOutput(BaseModel):
    """Aggregated recommendation split for the place detail summary."""

    recommended_count: int
    not_recommended_count: int
    recommended_percentage: int | None
    not_recommended_percentage: int | None


class PlaceReviewsSummaryOutput(BaseModel):
    """Read model returned for the place detail review summary."""

    place_id: str
    total_reviews: int
    average_rating: float | None
    criteria_ratings: list[CriterionRatingOutput]
    recommendation_summary: RecommendationSummaryOutput
    recent_reviews: list[RecentReviewOutput]


class PlaceReviewsOutput(BaseModel):
    """Read model returned for all reviews of a place."""

    place_id: str
    reviews: list[RecentReviewOutput]
