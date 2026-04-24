class UserAlreadyExistsError(Exception):
    """Raised when registration is attempted with an existing email."""


class InvalidCredentialsError(Exception):
    """Raised when authentication credentials are invalid."""

