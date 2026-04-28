from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from src.modules.auth.infra.database import models as auth_models  # noqa: F401
from src.modules.places.infra.database.bootstrap import seed_places_taxonomy
from src.modules.places.infra.database import models as place_models  # noqa: F401
from src.modules.reviews.infra.database import models as review_models  # noqa: F401
from src.modules.users.infra.database import models as user_models  # noqa: F401
from src.main import app
from src.shared.infra.database.base import Base
from src.shared.infra.database.session import get_db_session


@pytest.fixture
def db_session() -> Generator[Session, None, None]:
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
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
