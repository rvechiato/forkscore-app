from dataclasses import dataclass
from datetime import date, datetime
from typing import Optional
from uuid import UUID


@dataclass(frozen=True)
class Profile:
    """Basic profile linked to an authenticated user."""

    user_id: UUID
    name: str
    birth_date: Optional[date]
    created_at: datetime
    updated_at: datetime
