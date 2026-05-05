from collections.abc import Generator
import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

TEST_DATABASE_URL = os.environ.get("TEST_DATABASE_URL")
if TEST_DATABASE_URL:
    os.environ["DATABASE_URL"] = TEST_DATABASE_URL
else:
    os.environ.setdefault("DATABASE_URL", "sqlite://")

from src.modules.auth.infra.database import models as auth_models  # noqa: E402, F401
from src.modules.places.infra.database import models as place_models  # noqa: E402, F401
from src.modules.places.infra.database.bootstrap import seed_places_taxonomy  # noqa: E402
from src.modules.reviews.infra.database import models as review_models  # noqa: E402, F401
from src.modules.users.infra.database import models as user_models  # noqa: E402, F401
from src.main import app  # noqa: E402
from src.shared.infra.database.base import Base  # noqa: E402
from src.shared.infra.database.session import get_db_session  # noqa: E402


def _test_database_url() -> str:
    return os.environ["DATABASE_URL"]


@pytest.fixture
def db_session() -> Generator[Session, None, None]:
    database_url = _test_database_url()
    engine_options: dict[str, object] = {}
    if database_url.startswith("sqlite"):
        engine_options["connect_args"] = {"check_same_thread": False}
        if database_url in {"sqlite://", "sqlite:///:memory:"}:
            engine_options["poolclass"] = StaticPool

    engine = create_engine(database_url, **engine_options)
    TestingSessionLocal = sessionmaker(
        bind=engine,
        autoflush=False,
        autocommit=False,
        expire_on_commit=False,
    )
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    seed_places_taxonomy(session)
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


@pytest.fixture
def client(db_session: Session) -> Generator[TestClient, None, None]:
    def override_get_db_session() -> Generator[Session, None, None]:
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db_session] = override_get_db_session

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
