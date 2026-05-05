from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass(frozen=True)
class Place:
    """Registered place in the MVP catalog."""

    id: UUID
    name: str
    street: str
    number: str
    neighborhood: str
    city: str
    category_id: UUID
    subcategory_id: UUID
    instagram_url: str | None
    latitude: float | None
    longitude: float | None
    created_by_user_id: str
    created_at: datetime
    updated_at: datetime
