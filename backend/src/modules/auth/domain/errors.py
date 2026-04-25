class UserAlreadyExistsError(Exception):
    """Raised when registration is attempted with an existing email."""


class InvalidCredentialsError(Exception):
    """Raised when authentication credentials are invalid."""


class InvalidAccessTokenError(Exception):
    """Raised when an access token is invalid or expired."""
