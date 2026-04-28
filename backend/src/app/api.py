from fastapi import APIRouter

from src.modules.auth.presentation.api.router import router as auth_router
from src.modules.health.presentation.api.router import router as health_router
from src.modules.places.presentation.api.router import router as places_router
from src.modules.reviews.presentation.api.router import router as reviews_router
from src.modules.users.presentation.api.router import router as users_router


api_router = APIRouter()
api_router.include_router(health_router)
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(places_router)
api_router.include_router(reviews_router)
