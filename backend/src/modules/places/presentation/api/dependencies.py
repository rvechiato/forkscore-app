from fastapi import Depends
from sqlalchemy.orm import Session

from src.modules.auth.presentation.api.dependencies import get_profile_repository
from src.modules.places.application.use_cases.create_place import CreatePlace
from src.modules.places.application.use_cases.get_place_by_id import GetPlaceById
from src.modules.places.application.use_cases.list_places import ListPlaces
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.places.infra.repositories.sqlalchemy_place_repository import (
    SqlAlchemyPlaceRepository,
)
from src.modules.users.domain.ports.profile_repository import ProfileRepository
from src.shared.infra.database.session import get_db_session


def get_place_repository(
    session: Session = Depends(get_db_session),
) -> PlaceRepository:
    """Provide a place repository backed by the current database session."""

    return SqlAlchemyPlaceRepository(session=session)


def get_create_place_use_case(
    place_repository: PlaceRepository = Depends(get_place_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> CreatePlace:
    """Provide the create place use case."""

    return CreatePlace(
        place_repository=place_repository,
        profile_repository=profile_repository,
    )


def get_list_places_use_case(
    place_repository: PlaceRepository = Depends(get_place_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> ListPlaces:
    """Provide the list places use case."""

    return ListPlaces(
        place_repository=place_repository,
        profile_repository=profile_repository,
    )


def get_place_by_id_use_case(
    place_repository: PlaceRepository = Depends(get_place_repository),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> GetPlaceById:
    """Provide the get place by id use case."""

    return GetPlaceById(
        place_repository=place_repository,
        profile_repository=profile_repository,
    )
