import 'package:flutter/material.dart';

import '../auth_scope.dart';
import 'app_routes.dart';

class AppRouteGuard extends StatefulWidget {
  const AppRouteGuard({
    super.key,
    required this.routeName,
    required this.access,
    this.routeArguments,
    required this.child,
  });

  final String routeName;
  final AppRouteAccess access;
  final Object? routeArguments;
  final Widget child;

  @override
  State<AppRouteGuard> createState() => _AppRouteGuardState();
}

class _AppRouteGuardState extends State<AppRouteGuard> {
  String? _scheduledRedirect;

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final redirectTarget = _redirectTargetFor(
      sessionController.isAuthenticated,
    );

    if (redirectTarget == null) {
      _scheduledRedirect = null;
      return widget.child;
    }

    if (_scheduledRedirect != redirectTarget.routeName) {
      _scheduledRedirect = redirectTarget.routeName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushNamedAndRemoveUntil(
          redirectTarget.routeName,
          (route) => false,
          arguments: redirectTarget.arguments,
        );
      });
    }

    return const SizedBox.shrink();
  }

  _RedirectTarget? _redirectTargetFor(bool isAuthenticated) {
    if (widget.access == AppRouteAccess.authenticated && !isAuthenticated) {
      return _RedirectTarget(
        routeName: AppRoutes.login,
        arguments: LoginRouteArgs(redirectAfterLogin: widget.routeName),
      );
    }

    if (widget.access == AppRouteAccess.publicOnly && isAuthenticated) {
      return _RedirectTarget(
        routeName: _authenticatedRedirectTarget,
        arguments: null,
      );
    }

    return null;
  }

  String get _authenticatedRedirectTarget {
    if (widget.routeArguments case final LoginRouteArgs args?) {
      return args.redirectAfterLogin ?? AppRoutes.home;
    }

    if (widget.routeArguments case final RegisterRouteArgs args?) {
      return args.redirectAfterAuth ?? AppRoutes.home;
    }

    return AppRoutes.home;
  }
}

class _RedirectTarget {
  const _RedirectTarget({required this.routeName, required this.arguments});

  final String routeName;
  final Object? arguments;
}
