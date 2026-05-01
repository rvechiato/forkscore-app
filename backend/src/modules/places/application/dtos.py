from datetime import datetime

from pydantic import BaseModel, Field, field_validator


class CreatePlaceInput(BaseModel):
    """Input payload for creating a place."""

    name: str = Field(min_length=1, max_length=120)
    street: str = Field(min_length=1, max_length=120)
    number: str = Field(min_length=1, max_length=20)
    neighborhood: str = Field(min_length=1, max_length=80)
    city: str = Field(min_length=1, max_length=80)
    category_id: str = Field(min_length=1, max_length=64)
    subcategory_id: str = Field(min_length=1, max_length=64)

    @field_validator(
        "name",
        "street",
        "number",
        "neighborhood",
        "city",
        "category_id",
        "subcategory_id",
    )
    @classmethod
    def validate_non_blank(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("Field cannot be blank.")
        return normalized


class PlaceCategoryOutput(BaseModel):
    """Read payload for a place category."""

    id: str
    name: str
    slug: str


class PlaceSubcategoryOutput(BaseModel):
    """Read payload for a place subcategory."""

    id: str
    category_id: str
    name: str
    slug: str


class PlaceAuthorOutput(BaseModel):
    """Minimal author information for place payloads."""

    id: str
    name: str | None = None


class PlaceReviewSummaryBriefOutput(BaseModel):
    """Compact review summary for place list rows."""

    total_reviews: int
    average_rating: float | None = None


class PlaceSummaryOutput(BaseModel):
    """List payload for a registered place."""

    id: str
    name: str
    neighborhood: str
    city: str
    category_id: str
    subcategory_id: str
    category: PlaceCategoryOutput
    subcategory: PlaceSubcategoryOutput
    created_by: PlaceAuthorOutput
    review_summary: PlaceReviewSummaryBriefOutput


class PlaceDetailOutput(BaseModel):
    """Detailed payload for a registered place."""

    id: str
    name: str
    street: str
    number: str
    neighborhood: str
    city: str
    category_id: str
    subcategory_id: str
    category: PlaceCategoryOutput
    subcategory: PlaceSubcategoryOutput
    created_by: PlaceAuthorOutput
    created_at: datetime
    updated_at: datetime
