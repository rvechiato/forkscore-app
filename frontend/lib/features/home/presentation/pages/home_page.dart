import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/forkscore_logo.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useWideLayout = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              useWideLayout ? 56 : 24,
              40,
              useWideLayout ? 56 : 24,
              60,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopNav(
                      userName: userName,
                      onLogout: () {
                        sessionController.logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 56),
                    Text(
                      'Bem-vindo, $userName.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    PlacesDiscoverySection(
                      repository: widget.repository,
                      accessTokenProvider: () =>
                          sessionController.session?.accessToken,
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.userName, required this.onLogout});

  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ForkScoreLogo(
          showWordmark: true,
          compact: true,
          markWidth: 28,
          wordmarkSize: 18,
        ),
        const Spacer(),
        Text(
          userName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
          child: const Text('Perfil'),
        ),
        const SizedBox(width: 8),
        TextButton(onPressed: onLogout, child: const Text('Sair')),
      ],
    );
  }
}
