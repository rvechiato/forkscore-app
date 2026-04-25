import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../pages/auth_shell_page.dart';

class AuthPreviewNav extends StatelessWidget {
  const AuthPreviewNav({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final AuthFlowScreen current;
  final ValueChanged<AuthFlowScreen> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PreviewNavButton(
            label: 'Login',
            active: current == AuthFlowScreen.login,
            onTap: () => onSelect(AuthFlowScreen.login),
          ),
          _PreviewNavButton(
            label: 'Cadastro',
            active: current == AuthFlowScreen.register,
            onTap: () => onSelect(AuthFlowScreen.register),
          ),
          _PreviewNavButton(
            label: 'Home',
            active: current == AuthFlowScreen.home,
            onTap: () => onSelect(AuthFlowScreen.home),
          ),
        ],
      ),
    );
  }
}

class _PreviewNavButton extends StatelessWidget {
  const _PreviewNavButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: active ? AppTheme.terracotta : AppTheme.charcoal,
          textStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
