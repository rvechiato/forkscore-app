from dataclasses import dataclass


@dataclass(frozen=True)
class SystemStatus:
    """Represents the public operational status of the API."""

    name: str
    environment: str
    status: str

