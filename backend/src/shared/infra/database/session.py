from collections.abc import Generator
from functools import lru_cache

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from src.app.settings import Settings, get_settings
from src.shared.infra.database.base import Base


def _engine_options(database_url: str) -> dict[str, object]:
    options: dict[str, object] = {}
    if database_url.startswith("sqlite"):
        options["connect_args"] = {"check_same_thread": False}
    return options


@lru_cache
def get_engine(database_url: str) -> Engine:
    """Create a cached SQLAlchemy engine for the configured database."""

    return create_engine(database_url, **_engine_options(database_url))


@lru_cache
def get_session_factory(database_url: str) -> sessionmaker[Session]:
    """Create a cached session factory for the configured database."""

    return sessionmaker(
        bind=get_engine(database_url),
        autoflush=False,
        autocommit=False,
        expire_on_commit=False,
    )


def init_database(settings: Settings) -> None:
    """Create database tables for the current application."""

    # Import models before metadata creation so SQLAlchemy can register them.
    from src.modules.auth.infra.database import models  # noqa: F401

    Base.metadata.create_all(bind=get_engine(settings.database_url))


def get_db_session() -> Generator[Session, None, None]:
    """Yield a database session for a request lifecycle."""

    settings = get_settings()
    session_factory = get_session_factory(settings.database_url)
    session = session_factory()
    try:
        yield session
    finally:
        session.close()

