from fastapi import APIRouter

from src.modules.auth.presentation.api.router import router as auth_router
from src.modules.health.presentation.api.router import router as health_router


api_router = APIRouter()
api_router.include_router(health_router)
api_router.include_router(auth_router)

