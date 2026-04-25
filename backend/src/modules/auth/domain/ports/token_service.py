from typing import Protocol


class TokenService(Protocol):
    """Port for access token generation."""

    def create_access_token(self, subject: str) -> str:
        """Generate an access token for a subject identifier."""

    def get_subject(self, token: str) -> str:
        """Extract the subject identifier from a token."""
