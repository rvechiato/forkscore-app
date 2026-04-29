import 'package:flutter/material.dart';

import '../features/auth/application/auth_session_storage.dart';
import '../features/auth/data/forkscore_api_auth_repository.dart';
import '../features/auth/data/mock_auth_repository.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/places/data/forkscore_api_places_repository.dart';
import '../features/places/data/mock_places_repository.dart';
import '../features/places/domain/places_repository.dart';
import '../features/reviews/data/forkscore_api_reviews_repository.dart';
import '../features/reviews/data/mock_reviews_repository.dart';
import '../features/reviews/domain/reviews_repository.dart';
import '../shared/theme/app_theme.dart';
import 'auth_scope.dart';
import 'config/app_environment.dart';
import 'navigation/app_router.dart';
import 'navigation/app_routes.dart';

class ForkScoreApp extends StatefulWidget {
  const ForkScoreApp({
    super.key,
    this.initialRoute = AppRoutes.login,
    SessionController? sessionController,
    AuthSessionStorage? sessionStorage,
    PlacesRepository? placesRepository,
    ReviewsRepository? reviewsRepository,
  }) : _sessionController = sessionController,
       _sessionStorage = sessionStorage,
       _placesRepository = placesRepository,
       _reviewsRepository = reviewsRepository;

  final String initialRoute;
  final SessionController? _sessionController;
  final AuthSessionStorage? _sessionStorage;
  final PlacesRepository? _placesRepository;
  final ReviewsRepository? _reviewsRepository;

  @override
  State<ForkScoreApp> createState() => _ForkScoreAppState();
}

class _ForkScoreAppState extends State<ForkScoreApp> {
  late final SessionController _sessionController;
  late final bool _ownsSessionController;
  late final PlacesRepository _placesRepository;
  late final ReviewsRepository _reviewsRepository;

  @override
  void initState() {
    super.initState();
    _ownsSessionController = widget._sessionController == null;
    final useMocks = AppEnvironment.useMocks;

    _sessionController =
        widget._sessionController ??
        SessionController(
          repository: useMocks
              ? MockAuthRepository()
              : ForkScoreApiAuthRepository(baseUrl: AppEnvironment.apiBaseUrl),
          sessionStorage: widget._sessionStorage,
        );
    _placesRepository =
        widget._placesRepository ??
        (useMocks
            ? MockPlacesRepository()
            : ForkScoreApiPlacesRepository(baseUrl: AppEnvironment.apiBaseUrl));
    _reviewsRepository =
        widget._reviewsRepository ??
        (useMocks
            ? MockReviewsRepository()
            : ForkScoreApiReviewsRepository(
                baseUrl: AppEnvironment.apiBaseUrl,
              ));
  }

  @override
  void dispose() {
    if (_ownsSessionController) {
      _sessionController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      controller: _sessionController,
      child: MaterialApp(
        title: 'ForkScore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: widget.initialRoute,
        onGenerateRoute: AppRouter(
          placesRepository: _placesRepository,
          reviewsRepository: _reviewsRepository,
        ).onGenerateRoute,
      ),
    );
  }
}
