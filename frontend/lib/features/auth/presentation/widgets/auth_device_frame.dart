import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../pages/auth_shell_page.dart';
import 'auth_preview_nav.dart';

class AuthDeviceFrame extends StatelessWidget {
  const AuthDeviceFrame({
    super.key,
    required this.useWebLayout,
    required this.currentScreen,
    required this.onSelectScreen,
    required this.child,
  });

  final bool useWebLayout;
  final AuthFlowScreen currentScreen;
  final ValueChanged<AuthFlowScreen> onSelectScreen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (useWebLayout) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 28,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _WebTopBar(
                  currentScreen: currentScreen,
                  onSelectScreen: onSelectScreen,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      );
    }

    return ColoredBox(color: AppTheme.background, child: child);
  }
}

class _WebTopBar extends StatelessWidget {
  const _WebTopBar({required this.currentScreen, required this.onSelectScreen});

  final AuthFlowScreen currentScreen;
  final ValueChanged<AuthFlowScreen> onSelectScreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.inputBorder)),
      ),
      child: Row(
        children: [
          Text(
            'ForkScore',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 28),
          ),
          const Spacer(),
          AuthPreviewNav(
            current: currentScreen,
            onSelect: onSelectScreen,
            compact: true,
          ),
        ],
      ),
    );
  }
}
