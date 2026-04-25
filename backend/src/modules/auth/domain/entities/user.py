from dataclasses import dataclass
from datetime import datetime
from uuid import UUID


@dataclass(frozen=True)
class User:
    """Authenticated user representation."""

    id: UUID
    email: str
    password_hash: str
    created_at: datetime
