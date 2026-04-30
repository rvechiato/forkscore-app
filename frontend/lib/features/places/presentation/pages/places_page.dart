import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/widgets/authenticated_page_scaffold.dart';
import '../../domain/places_repository.dart';
import '../../../reviews/domain/reviews_repository.dart';
import '../widgets/place_discovery_section.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({
    super.key,
    required this.repository,
    required this.reviewsRepository,
  });

  final PlacesRepository repository;
  final ReviewsRepository reviewsRepository;

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final userName = sessionController.currentUser?.name ?? 'Gastronomo';

    return AuthenticatedPageScaffold(
      showBackButton: true,
      child: PlacesDiscoverySection(
        repository: repository,
        reviewsRepository: reviewsRepository,
        accessTokenProvider: () => sessionController.session?.accessToken,
        currentUserName: userName,
        onReviewPlaceSelected: (place) {
          Navigator.of(context).pushNamed(
            AppRoutes.reviews,
            arguments: ReviewsRouteArgs(initialPlace: place),
          );
        },
      ),
    );
  }
}
