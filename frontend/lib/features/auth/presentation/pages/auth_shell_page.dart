import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../widgets/auth_device_frame.dart';
import 'login_page.dart';
import 'register_page.dart';

enum AuthFlowScreen { login, register, home }

class AuthShellPage extends StatefulWidget {
  const AuthShellPage({super.key});

  @override
  State<AuthShellPage> createState() => _AuthShellPageState();
}

class _AuthShellPageState extends State<AuthShellPage> {
  AuthFlowScreen _screen = AuthFlowScreen.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useDeviceFrame = constraints.maxWidth >= 640;
          final showPreviewNav = useDeviceFrame && constraints.maxHeight >= 860;

          return ColoredBox(
            color: useDeviceFrame ? AppTheme.previewBackdrop : AppTheme.cream,
            child: Center(
              child: AuthDeviceFrame(
                useDeviceFrame: useDeviceFrame,
                currentScreen: _screen,
                showPreviewNav: showPreviewNav,
                onSelectScreen: (screen) => setState(() => _screen = screen),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: switch (_screen) {
                    AuthFlowScreen.login => LoginPage(
                      key: const ValueKey('login-page'),
                      onEnter: _goHome,
                      onCreateAccount: () {
                        setState(() => _screen = AuthFlowScreen.register);
                      },
                    ),
                    AuthFlowScreen.register => RegisterPage(
                      key: const ValueKey('register-page'),
                      onBack: () {
                        setState(() => _screen = AuthFlowScreen.login);
                      },
                      onSubmit: _goHome,
                    ),
                    AuthFlowScreen.home => const HomePage(
                      key: ValueKey('home-page'),
                      userName: 'Gastronomo',
                    ),
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _goHome() {
    setState(() => _screen = AuthFlowScreen.home);
  }
}
