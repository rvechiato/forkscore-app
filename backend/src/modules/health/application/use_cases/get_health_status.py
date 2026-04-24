from src.app.settings import Settings
from src.modules.health.domain.entities.system_status import SystemStatus


class GetHealthStatus:
    """Return a simple API status payload."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    def execute(self) -> SystemStatus:
        """Build the current API status."""

        return SystemStatus(
            name=self._settings.app_name,
            environment=self._settings.app_env,
            status="ok",
        )

