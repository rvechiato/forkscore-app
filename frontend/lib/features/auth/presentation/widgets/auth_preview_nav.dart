import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../pages/auth_shell_page.dart';

class AuthPreviewNav extends StatelessWidget {
  const AuthPreviewNav({
    super.key,
    required this.current,
    required this.onSelect,
    this.compact = false,
  });

  final AuthFlowScreen current;
  final ValueChanged<AuthFlowScreen> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 18,
        vertical: compact ? 4 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: compact
            ? null
            : const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
        border: compact ? Border.all(color: AppTheme.inputBorder) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PreviewNavButton(
            label: 'Login',
            active: current == AuthFlowScreen.login,
            compact: compact,
            onTap: () => onSelect(AuthFlowScreen.login),
          ),
          _PreviewNavButton(
            label: 'Cadastro',
            active: current == AuthFlowScreen.register,
            compact: compact,
            onTap: () => onSelect(AuthFlowScreen.register),
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
    required this.compact,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: active
              ? AppTheme.primaryBrand
              : AppTheme.textPrimary,
          backgroundColor: active && compact
              ? AppTheme.primaryBrand.withValues(alpha: 0.08)
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
