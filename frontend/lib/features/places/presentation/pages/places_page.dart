import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/places_repository.dart';
import '../widgets/place_discovery_section.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({super.key, required this.repository});

  final PlacesRepository repository;

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final userName = sessionController.currentUser?.name ?? 'Gastronomo';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Pesquisa de Lugares'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: PlacesDiscoverySection(
              repository: repository,
              accessTokenProvider: () => sessionController.session?.accessToken,
              currentUserName: userName,
              onReviewPlaceSelected: (place) {
                Navigator.of(context).pushNamed(
                  AppRoutes.reviews,
                  arguments: ReviewsRouteArgs(initialPlace: place),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
