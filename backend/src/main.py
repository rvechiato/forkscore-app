from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.app.api import api_router
from src.app.settings import get_settings
from src.shared.infra.database.session import init_database


settings = get_settings()


@asynccontextmanager
async def lifespan(_: FastAPI):
    """Initialize application resources on startup."""

    init_database(settings)
    yield

app = FastAPI(
    title=settings.app_name,
    debug=settings.app_debug,
    version="0.1.0",
    summary="API RESTful do ForkScore.",
    lifespan=lifespan,
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(api_router)
