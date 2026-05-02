import 'package:flutter/material.dart';

import '../../app/auth_scope.dart';
import '../../app/navigation/app_routes.dart';
import '../theme/app_theme.dart';
import 'forkscore_logo.dart';

class AuthenticatedPageScaffold extends StatelessWidget {
  const AuthenticatedPageScaffold({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 56, 24, 40),
    this.showBackButton = false,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry contentPadding;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final userName = sessionController.currentUser?.name ?? 'Gastronomo';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 900
              ? 56.0
              : constraints.maxWidth < 430
              ? 16.0
              : 24.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    constraints.maxWidth < 430 ? 28 : 40,
                    horizontalPadding,
                    24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _AuthenticatedTopNav(
                        userName: userName,
                        showBackButton: showBackButton,
                        onLogout: () {
                          sessionController.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const _TopAreaDivider(),
                Padding(
                  padding: contentPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AuthenticatedTopNav extends StatelessWidget {
  const _AuthenticatedTopNav({
    required this.userName,
    required this.showBackButton,
    required this.onLogout,
  });

  final String userName;
  final bool showBackButton;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;

        return Row(
          children: [
            if (showBackButton && Navigator.of(context).canPop()) ...[
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 8),
            ],
            ForkScoreLogo(
              showWordmark: !compact,
              compact: true,
              markWidth: 28,
              wordmarkSize: 18,
              subtitle: compact ? null : 'the society',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      'Olá, $userName',
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                    child: const Text('Perfil'),
                  ),
                  const SizedBox(width: 4),
                  TextButton(onPressed: onLogout, child: const Text('Sair')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopAreaDivider extends StatelessWidget {
  const _TopAreaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppTheme.inputBorder);
  }
}
