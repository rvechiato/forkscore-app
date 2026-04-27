from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass(frozen=True)
class Category:
    """Top-level gastronomic category for places."""

    id: UUID
    name: str
    slug: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
