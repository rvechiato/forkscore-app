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
    created_by_user_id: str
    created_at: datetime
    updated_at: datetime
