import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/auth_shell_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/places/domain/places_repository.dart';
import '../../features/places/presentation/pages/places_page.dart';
import '../../features/reviews/domain/reviews_repository.dart';
import '../../features/reviews/presentation/pages/reviews_page.dart';
import 'app_route_guard.dart';
import 'app_routes.dart';
import 'protected_placeholder_page.dart';

class AppRouter {
  AppRouter({
    required PlacesRepository placesRepository,
    required ReviewsRepository reviewsRepository,
  }) : _placesRepository = placesRepository,
       _reviewsRepository = reviewsRepository;

  final PlacesRepository _placesRepository;
  final ReviewsRepository _reviewsRepository;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final requestedRouteName = settings.name ?? AppRoutes.login;
    final routeName = AppRoutes.all.contains(requestedRouteName)
        ? requestedRouteName
        : AppRoutes.login;

    return MaterialPageRoute<void>(
      settings: RouteSettings(name: routeName, arguments: settings.arguments),
      builder: (context) => _buildGuardedPage(routeName, settings),
    );
  }

  Widget _buildGuardedPage(String routeName, RouteSettings settings) {
    final access = AppRoutes.publicRoutes.contains(routeName)
        ? AppRouteAccess.publicOnly
        : AppRouteAccess.authenticated;

    return AppRouteGuard(
      routeName: routeName,
      access: access,
      routeArguments: settings.arguments,
      child: _buildPage(routeName, settings.arguments),
    );
  }

  Widget _buildPage(String routeName, Object? arguments) {
    return switch (routeName) {
      AppRoutes.login => AuthShellPage(
        currentScreen: AuthFlowScreen.login,
        redirectAfterAuth: _loginArgs(arguments).redirectAfterLogin,
        child: LoginPage(
          key: const ValueKey('login-page'),
          redirectAfterLogin: _loginArgs(arguments).redirectAfterLogin,
        ),
      ),
      AppRoutes.register => AuthShellPage(
        currentScreen: AuthFlowScreen.register,
        redirectAfterAuth: _registerArgs(arguments).redirectAfterAuth,
        child: RegisterPage(
          key: const ValueKey('register-page'),
          redirectAfterAuth: _registerArgs(arguments).redirectAfterAuth,
        ),
      ),
      AppRoutes.home => HomePage(
        key: const ValueKey('home-page'),
        repository: _placesRepository,
      ),
      AppRoutes.profile => const ProtectedPlaceholderPage(
        title: 'Perfil',
        description:
            'Aqui entra o fluxo do perfil autenticado do usuario no MVP.',
      ),
      AppRoutes.places => PlacesPage(
        key: const ValueKey('places-page'),
        repository: _placesRepository,
      ),
      AppRoutes.reviews => ReviewsPage(
        key: const ValueKey('reviews-page'),
        reviewsRepository: _reviewsRepository,
        placesRepository: _placesRepository,
        initialPlace: _reviewsArgs(arguments).initialPlace,
      ),
      _ => AuthShellPage(
        currentScreen: AuthFlowScreen.login,
        child: const LoginPage(key: ValueKey('login-page')),
      ),
    };
  }

  LoginRouteArgs _loginArgs(Object? arguments) {
    return arguments is LoginRouteArgs ? arguments : const LoginRouteArgs();
  }

  RegisterRouteArgs _registerArgs(Object? arguments) {
    return arguments is RegisterRouteArgs
        ? arguments
        : const RegisterRouteArgs();
  }

  ReviewsRouteArgs _reviewsArgs(Object? arguments) {
    return arguments is ReviewsRouteArgs
        ? arguments
        : const ReviewsRouteArgs();
  }
}
