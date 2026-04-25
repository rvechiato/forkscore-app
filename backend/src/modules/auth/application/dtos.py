from datetime import date
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class RegisterUserInput(BaseModel):
    """Input DTO for user registration."""

    name: str = Field(min_length=2, max_length=80)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginInput(BaseModel):
    """Input DTO for authentication."""

    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class AuthTokenOutput(BaseModel):
    """Authentication response DTO."""

    access_token: str
    token_type: str = "bearer"


class AuthenticatedUserOutput(BaseModel):
    """Public user payload returned by auth endpoints."""

    id: str
    name: str
    birth_date: Optional[date] = None
    age: Optional[int] = None
    email: EmailStr


class AuthSuccessOutput(BaseModel):
    """Authentication success response payload."""

    access_token: str
    token_type: str = "bearer"
    user: AuthenticatedUserOutput
