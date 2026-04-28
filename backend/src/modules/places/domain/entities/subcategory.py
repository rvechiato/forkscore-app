from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass(frozen=True)
class Subcategory:
    """Second-level gastronomic category bound to a category."""

    id: UUID
    category_id: UUID
    name: str
    slug: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
