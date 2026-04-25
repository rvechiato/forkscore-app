from datetime import date

from pydantic import BaseModel, EmailStr, Field


class MyProfileOutput(BaseModel):
    """Authenticated profile response payload."""

    id: str
    name: str
    birth_date: date
    age: int
    email: EmailStr


class UpdateMyProfileInput(BaseModel):
    """Editable profile payload for the authenticated user."""

    name: str = Field(min_length=2, max_length=80)
    birth_date: date
    email: EmailStr
