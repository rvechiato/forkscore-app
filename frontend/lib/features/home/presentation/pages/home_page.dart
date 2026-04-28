import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/forkscore_logo.dart';
import '../../../places/domain/places_repository.dart';
import '../../../places/presentation/widgets/place_discovery_section.dart';
import '../../../reviews/domain/reviews_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
    required this.reviewsRepository,
  });

  final PlacesRepository repository;
  final ReviewsRepository reviewsRepository;

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
                      reviewsRepository: widget.reviewsRepository,
                      accessTokenProvider: () =>
                          sessionController.session?.accessToken,
                      currentUserName: userName,
                      onReviewPlaceSelected: (place) {
                        Navigator.of(context).pushNamed(
                          AppRoutes.reviews,
                          arguments: ReviewsRouteArgs(initialPlace: place),
                        );
                      },
                      title: 'Escolha, experimente e avalie',
                      titleFontSize: 32,
                      eyebrow: '',
                      description: '',
                      showHeroDivider: false,
                    ),
                    const SizedBox(height: 32),
                    const _FavoritesPlaceholder(),
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

class _FavoritesPlaceholder extends StatelessWidget {
  const _FavoritesPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Espaco reservado para favoritos',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Quando o MVP evoluir, esta area podera destacar lugares salvos '
            'pelo usuario sem exigir nova mudanca estrutural na home.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
