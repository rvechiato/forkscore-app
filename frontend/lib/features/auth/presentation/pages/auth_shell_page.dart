import 'package:flutter/material.dart';

import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../widgets/auth_device_frame.dart';

enum AuthFlowScreen { login, register }

class AuthShellPage extends StatelessWidget {
  const AuthShellPage({
    super.key,
    required this.currentScreen,
    required this.child,
    this.redirectAfterAuth,
  });

  final AuthFlowScreen currentScreen;
  final Widget child;
  final String? redirectAfterAuth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useWebLayout = constraints.maxWidth >= 900;
          final isLogin = currentScreen == AuthFlowScreen.login;

          return ColoredBox(
            color: useWebLayout
                ? AppTheme.previewBackdrop
                : AppTheme.background,
            child: Center(
              child: isLogin
                  ? child
                  : AuthDeviceFrame(
                      useWebLayout: useWebLayout,
                      currentScreen: currentScreen,
                      onSelectScreen: (screen) =>
                          _navigateToScreen(context, screen),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: child,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToScreen(BuildContext context, AuthFlowScreen screen) {
    final routeName = switch (screen) {
      AuthFlowScreen.login => AppRoutes.login,
      AuthFlowScreen.register => AppRoutes.register,
    };

    final arguments = switch (screen) {
      AuthFlowScreen.login => LoginRouteArgs(
        redirectAfterLogin: redirectAfterAuth,
      ),
      AuthFlowScreen.register => RegisterRouteArgs(
        redirectAfterAuth: redirectAfterAuth,
      ),
    };

    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }
}
