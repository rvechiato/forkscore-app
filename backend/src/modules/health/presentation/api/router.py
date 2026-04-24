from fastapi import APIRouter
from pydantic import BaseModel

from src.app.settings import get_settings
from src.modules.health.application.use_cases.get_health_status import (
    GetHealthStatus,
)


router = APIRouter(prefix="/health", tags=["health"])


class HealthResponse(BaseModel):
    """Response model for health-check endpoint."""

    name: str
    environment: str
    status: str


@router.get("", response_model=HealthResponse, summary="Health-check da API")
def get_health() -> HealthResponse:
    """Return a basic operational status for monitoring and smoke tests."""

    use_case = GetHealthStatus(settings=get_settings())
    result = use_case.execute()
    return HealthResponse.model_validate(result.__dict__)

