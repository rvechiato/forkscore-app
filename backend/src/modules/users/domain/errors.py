class ProfileNotFoundError(Exception):
    """Raised when a profile cannot be found."""


class EmailAlreadyInUseError(Exception):
    """Raised when profile update attempts to reuse an existing email."""
