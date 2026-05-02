from src.modules.places.application.dtos import (
    PlaceAuthorOutput,
    PlaceCategoryOutput,
    PlaceReviewSummaryBriefOutput,
    PlaceSubcategoryOutput,
    PlaceSummaryOutput,
)
from src.modules.places.domain.ports.category_repository import CategoryRepository
from src.modules.places.domain.ports.place_repository import PlaceRepository
from src.modules.places.domain.ports.subcategory_repository import (
    SubcategoryRepository,
)
from src.modules.reviews.domain.ports.review_repository import ReviewRepository
from src.modules.users.domain.ports.profile_repository import ProfileRepository


class ListPlaces:
    """List the places available in the MVP catalog."""

    def __init__(
        self,
        place_repository: PlaceRepository,
        category_repository: CategoryRepository,
        subcategory_repository: SubcategoryRepository,
        profile_repository: ProfileRepository,
        review_repository: ReviewRepository,
    ) -> None:
        self._place_repository = place_repository
        self._category_repository = category_repository
        self._subcategory_repository = subcategory_repository
        self._profile_repository = profile_repository
        self._review_repository = review_repository

    def execute(self) -> list[PlaceSummaryOutput]:
        places = self._place_repository.list_all()
        review_summaries = self._review_repository.summaries_by_place_ids(
            [str(place.id) for place in places],
        )
        results: list[PlaceSummaryOutput] = []

        for place in places:
            profile = self._profile_repository.find_by_user_id(place.created_by_user_id)
            category = self._category_repository.find_active_by_id(str(place.category_id))
            subcategory = self._subcategory_repository.find_active_by_id(
                str(place.subcategory_id),
            )
            review_summary = review_summaries.get(str(place.id))
            results.append(
                PlaceSummaryOutput(
                    id=str(place.id),
                    name=place.name,
                    neighborhood=place.neighborhood,
                    city=place.city,
                    category_id=str(place.category_id),
                    subcategory_id=str(place.subcategory_id),
                    instagram_url=place.instagram_url,
                    category=PlaceCategoryOutput(
                        id=str(place.category_id),
                        name="" if category is None else category.name,
                        slug="" if category is None else category.slug,
                    ),
                    subcategory=PlaceSubcategoryOutput(
                        id=str(place.subcategory_id),
                        category_id=str(place.category_id),
                        name="" if subcategory is None else subcategory.name,
                        slug="" if subcategory is None else subcategory.slug,
                    ),
                    created_by=PlaceAuthorOutput(
                        id=place.created_by_user_id,
                        name=None if profile is None else profile.name,
                    ),
                    review_summary=PlaceReviewSummaryBriefOutput(
                        total_reviews=0
                        if review_summary is None
                        else review_summary.total_reviews,
                        average_rating=None
                        if review_summary is None
                        else review_summary.average_rating,
                    ),
                )
            )

        return results
