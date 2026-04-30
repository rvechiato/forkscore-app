import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/authenticated_page_scaffold.dart';
import '../../../places/domain/places_repository.dart';
import '../../../places/presentation/widgets/place_discovery_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});

  final PlacesRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final userName = sessionController.currentUser?.name ?? 'Gastronomo';

    return AuthenticatedPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bem-vindo, $userName.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          PlacesDiscoverySection(
            repository: widget.repository,
            accessTokenProvider: () => sessionController.session?.accessToken,
            currentUserName: userName,
            showInlineDetail: false,
            onPlaceSelected: (place) {
              Navigator.of(context).pushNamed(
                AppRoutes.placeReviews,
                arguments: PlaceReviewsRouteArgs(placeId: place.id),
              );
            },
            title: 'Escolha, experimente e avalie',
            titleFontSize: 32,
            eyebrow: '',
            description: '',
            showHeroDivider: false,
          ),
        ],
      ),
    );
  }
}
