import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../pages/auth_shell_page.dart';
import 'auth_preview_nav.dart';

class AuthDeviceFrame extends StatelessWidget {
  const AuthDeviceFrame({
    super.key,
    required this.useDeviceFrame,
    required this.currentScreen,
    required this.showPreviewNav,
    required this.onSelectScreen,
    required this.child,
  });

  final bool useDeviceFrame;
  final AuthFlowScreen currentScreen;
  final bool showPreviewNav;
  final ValueChanged<AuthFlowScreen> onSelectScreen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: useDeviceFrame ? 24 : 0,
            vertical: useDeviceFrame ? 24 : 0,
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: useDeviceFrame ? 390 : double.infinity,
              maxHeight: useDeviceFrame ? 844 : double.infinity,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(useDeviceFrame ? 40 : 0),
              border: useDeviceFrame
                  ? Border.all(color: const Color(0xFF262322), width: 8)
                  : null,
              boxShadow: useDeviceFrame
                  ? const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 32,
                        offset: Offset(0, 20),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _StatusBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ),
        if (showPreviewNav)
          Positioned(
            bottom: 32,
            child: AuthPreviewNav(
              current: currentScreen,
              onSelect: onSelectScreen,
            ),
          ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      child: Row(
        children: [
          Text(
            '9:41',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
          const Spacer(),
          const Icon(Icons.menu_rounded, size: 16, color: Color(0xFF222222)),
          const SizedBox(width: 6),
          const Icon(Icons.public_rounded, size: 16, color: Color(0xFF222222)),
          const SizedBox(width: 6),
          const Icon(
            Icons.battery_full_rounded,
            size: 18,
            color: Color(0xFF222222),
          ),
        ],
      ),
    );
  }
}
