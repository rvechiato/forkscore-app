import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ForkScoreActionButton extends StatelessWidget {
  const ForkScoreActionButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.onPressed,
    this.foregroundColor = Colors.white,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ForkScoreActionButton(
      label: label,
      backgroundColor: AppTheme.terracotta,
      onPressed: onPressed,
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ForkScoreActionButton(
      label: label,
      backgroundColor: AppTheme.moss,
      onPressed: onPressed,
    );
  }
}
