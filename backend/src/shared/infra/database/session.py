from collections.abc import Generator
from functools import lru_cache

from sqlalchemy import create_engine, inspect, text
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
    from src.modules.auth.infra.database import models as auth_models  # noqa: F401
    from src.modules.places.infra.database import models as place_models  # noqa: F401
    from src.modules.users.infra.database import models as user_models  # noqa: F401

    engine = get_engine(settings.database_url)
    _run_sqlite_bootstrap_migrations(engine, settings.database_url)
    Base.metadata.create_all(bind=engine)


def get_db_session() -> Generator[Session, None, None]:
    """Yield a database session for a request lifecycle."""

    settings = get_settings()
    session_factory = get_session_factory(settings.database_url)
    session = session_factory()
    try:
        yield session
    finally:
        session.close()


def _run_sqlite_bootstrap_migrations(engine: Engine, database_url: str) -> None:
    """Apply lightweight SQLite bootstrap migrations for local development."""

    if not database_url.startswith("sqlite"):
        return

    inspector = inspect(engine)
    if "profiles" not in inspector.get_table_names():
        return

    columns = {column["name"]: column for column in inspector.get_columns("profiles")}
    birth_date = columns.get("birth_date")
    if birth_date is None or birth_date.get("nullable", True):
        return

    with engine.begin() as connection:
        connection.execute(text("PRAGMA foreign_keys=OFF"))
        connection.execute(
            text(
                """
                CREATE TABLE profiles__new (
                    user_id VARCHAR(36) NOT NULL PRIMARY KEY,
                    name VARCHAR(80) NOT NULL,
                    birth_date DATE NULL,
                    created_at DATETIME NOT NULL,
                    updated_at DATETIME NOT NULL,
                    FOREIGN KEY(user_id) REFERENCES users (id) ON DELETE CASCADE
                )
                """
            )
        )
        connection.execute(
            text(
                """
                INSERT INTO profiles__new (
                    user_id, name, birth_date, created_at, updated_at
                )
                SELECT user_id, name, birth_date, created_at, updated_at
                FROM profiles
                """
            )
        )
        connection.execute(text("DROP TABLE profiles"))
        connection.execute(text("ALTER TABLE profiles__new RENAME TO profiles"))
        connection.execute(text("PRAGMA foreign_keys=ON"))
