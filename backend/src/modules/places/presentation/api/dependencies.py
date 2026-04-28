from fastapi import Depends
from sqlalchemy.orm import Session

from src.modules.auth.presentation.api.dependencies import get_profile_repository
from src.modules.places.application.use_cases.create_place import CreatePlace
from src.modules.places.application.use_cases.get_place_by_id import GetPlaceById
from src.modules.places.application.use_cases.list_active_categories import (
    ListActiveCategories,
)
from src.modules.places.application.use_cases.list_active_subcategories import (
    ListActiveSubcategories,
)
from src.modules.places.application.use_cases.list_places import ListPlaces
from src.modules.places.domain.ports.category_repository import CategoryRepository
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.places.domain.ports.subcategory_repository import (
    SubcategoryRepository,
)
from src.modules.places.infra.repositories.sqlalchemy_category_repository import (
    SqlAlchemyCategoryRepository,
)
from src.modules.places.infra.repositories.sqlalchemy_place_repository import (
    SqlAlchemyPlaceRepository,
)
from src.modules.places.infra.repositories.sqlalchemy_subcategory_repository import (
    SqlAlchemySubcategoryRepository,
)
from src.modules.users.domain.ports.profile_repository import ProfileRepository
from src.shared.infra.database.session import get_db_session


def get_place_repository(
    session: Session = Depends(get_db_session),
) -> PlaceRepository:
    """Provide a place repository backed by the current database session."""

    return SqlAlchemyPlaceRepository(session=session)


def get_category_repository(
    session: Session = Depends(get_db_session),
) -> CategoryRepository:
    """Provide a category repository backed by the current database session."""

    return SqlAlchemyCategoryRepository(session=session)


def get_subcategory_repository(
    session: Session = Depends(get_db_session),
) -> SubcategoryRepository:
    """Provide a subcategory repository backed by the current database session."""

    return SqlAlchemySubcategoryRepository(session=session)


def get_create_place_use_case(
    place_repository: PlaceRepository = Depends(get_place_repository),
    category_repository: CategoryRepository = Depends(get_category_repository),
    subcategory_repository: SubcategoryRepository = Depends(
        get_subcategory_repository,
    ),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> CreatePlace:
    """Provide the create place use case."""

    return CreatePlace(
        place_repository=place_repository,
        category_repository=category_repository,
        subcategory_repository=subcategory_repository,
        profile_repository=profile_repository,
    )


def get_list_places_use_case(
    place_repository: PlaceRepository = Depends(get_place_repository),
    category_repository: CategoryRepository = Depends(get_category_repository),
    subcategory_repository: SubcategoryRepository = Depends(
        get_subcategory_repository,
    ),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> ListPlaces:
    """Provide the list places use case."""

    return ListPlaces(
        place_repository=place_repository,
        category_repository=category_repository,
        subcategory_repository=subcategory_repository,
        profile_repository=profile_repository,
    )


def get_place_by_id_use_case(
    place_repository: PlaceRepository = Depends(get_place_repository),
    category_repository: CategoryRepository = Depends(get_category_repository),
    subcategory_repository: SubcategoryRepository = Depends(
        get_subcategory_repository,
    ),
    profile_repository: ProfileRepository = Depends(get_profile_repository),
) -> GetPlaceById:
    """Provide the get place by id use case."""

    return GetPlaceById(
        place_repository=place_repository,
        category_repository=category_repository,
        subcategory_repository=subcategory_repository,
        profile_repository=profile_repository,
    )


def get_list_active_categories_use_case(
    category_repository: CategoryRepository = Depends(get_category_repository),
) -> ListActiveCategories:
    """Provide the list active categories use case."""

    return ListActiveCategories(category_repository=category_repository)


def get_list_active_subcategories_use_case(
    category_repository: CategoryRepository = Depends(get_category_repository),
    subcategory_repository: SubcategoryRepository = Depends(
        get_subcategory_repository,
    ),
) -> ListActiveSubcategories:
    """Provide the list active subcategories use case."""

    return ListActiveSubcategories(
        category_repository=category_repository,
        subcategory_repository=subcategory_repository,
    )
