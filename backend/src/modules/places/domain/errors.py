class PlaceNotFoundError(Exception):
    """Raised when a place cannot be found."""


class InvalidPlaceCategoryError(Exception):
    """Raised when a category is invalid or unavailable."""


class InvalidPlaceSubcategoryError(Exception):
    """Raised when a subcategory is invalid or unavailable."""
