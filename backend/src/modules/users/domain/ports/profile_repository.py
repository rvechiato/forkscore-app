from typing import Protocol

from src.modules.users.domain.entities.profile import Profile


class ProfileRepository(Protocol):
    """Port for profile persistence operations."""

    def save(self, profile: Profile) -> Profile:
        """Persist and return a profile."""

    def find_by_user_id(self, user_id: str) -> Profile | None:
        """Return the profile linked to a user identifier."""

    def update(self, profile: Profile) -> Profile:
        """Update and return a persisted profile."""
