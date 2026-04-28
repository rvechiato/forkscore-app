from fastapi import APIRouter, Depends, HTTPException, status

from src.modules.auth.domain.entities.user import User
from src.modules.auth.presentation.api.dependencies import get_current_user
from src.modules.places.application.dtos import (
    CreatePlaceInput,
    PlaceCategoryOutput,
    PlaceDetailOutput,
    PlaceSubcategoryOutput,
    PlaceSummaryOutput,
)
from src.modules.places.application.use_cases.create_place import CreatePlace
from src.modules.places.application.use_cases.get_place_by_id import GetPlaceById
from src.modules.places.application.use_cases.list_active_categories import (
    ListActiveCategories,
)
from src.modules.places.application.use_cases.list_active_subcategories import (
    ListActiveSubcategories,
)
from src.modules.places.application.use_cases.list_places import ListPlaces
from src.modules.places.domain.errors import (
    InvalidPlaceCategoryError,
    InvalidPlaceSubcategoryError,
    PlaceNotFoundError,
)
from src.modules.places.presentation.api.dependencies import (
    get_create_place_use_case,
    get_list_active_categories_use_case,
    get_list_active_subcategories_use_case,
    get_list_places_use_case,
    get_place_by_id_use_case,
)


router = APIRouter(prefix="/places", tags=["places"])


@router.post(
    "",
    response_model=PlaceDetailOutput,
    status_code=status.HTTP_201_CREATED,
    summary="Cadastrar local",
)
def create_place(
    payload: CreatePlaceInput,
    current_user: User = Depends(get_current_user),
    use_case: CreatePlace = Depends(get_create_place_use_case),
) -> PlaceDetailOutput:
    """Create a new place for the authenticated user."""
    try:
        return use_case.execute(str(current_user.id), payload)
    except InvalidPlaceCategoryError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        ) from exc
    except InvalidPlaceSubcategoryError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(exc),
        ) from exc


@router.get(
    "",
    response_model=list[PlaceSummaryOutput],
    status_code=status.HTTP_200_OK,
    summary="Listar locais",
)
def list_places(
    _: User = Depends(get_current_user),
    use_case: ListPlaces = Depends(get_list_places_use_case),
) -> list[PlaceSummaryOutput]:
    """List all places for the authenticated area."""

    return use_case.execute()


@router.get(
    "/categories",
    response_model=list[PlaceCategoryOutput],
    status_code=status.HTTP_200_OK,
    summary="Listar categorias de locais",
)
def list_categories(
    _: User = Depends(get_current_user),
    use_case: ListActiveCategories = Depends(get_list_active_categories_use_case),
) -> list[PlaceCategoryOutput]:
    """List active categories for place creation."""

    return use_case.execute()


@router.get(
    "/categories/{category_id}/subcategories",
    response_model=list[PlaceSubcategoryOutput],
    status_code=status.HTTP_200_OK,
    summary="Listar subcategorias por categoria",
)
def list_subcategories(
    category_id: str,
    _: User = Depends(get_current_user),
    use_case: ListActiveSubcategories = Depends(
        get_list_active_subcategories_use_case,
    ),
) -> list[PlaceSubcategoryOutput]:
    """List active subcategories scoped to a category."""

    try:
        return use_case.execute(category_id)
    except InvalidPlaceCategoryError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc


@router.get(
    "/{place_id}",
    response_model=PlaceDetailOutput,
    status_code=status.HTTP_200_OK,
    summary="Detalhar local",
)
def get_place_by_id(
    place_id: str,
    _: User = Depends(get_current_user),
    use_case: GetPlaceById = Depends(get_place_by_id_use_case),
) -> PlaceDetailOutput:
    """Return the place detail."""

    try:
        return use_case.execute(place_id)
    except PlaceNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(exc),
        ) from exc
