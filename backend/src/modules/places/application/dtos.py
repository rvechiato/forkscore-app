from datetime import datetime

from urllib.parse import urlparse

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
    instagram_url: str | None = Field(default=None, max_length=255)

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

    @field_validator("instagram_url")
    @classmethod
    def validate_instagram_url(cls, value: str | None) -> str | None:
        if value is None:
            return None

        normalized = value.strip()
        if not normalized:
            return None

        parsed = urlparse(normalized)
        if parsed.scheme not in {"http", "https"}:
            raise ValueError("Instagram URL must use http or https.")
        if parsed.netloc.lower() not in {"instagram.com", "www.instagram.com"}:
            raise ValueError("Instagram URL must use instagram.com.")

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
    instagram_url: str | None = None
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
    instagram_url: str | None = None
    category: PlaceCategoryOutput
    subcategory: PlaceSubcategoryOutput
    created_by: PlaceAuthorOutput
    created_at: datetime
    updated_at: datetime
