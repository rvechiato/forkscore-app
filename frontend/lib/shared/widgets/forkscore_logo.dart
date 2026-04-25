import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ForkScoreLogo extends StatelessWidget {
  const ForkScoreLogo({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final markSize = compact ? 54.0 : 92.0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: markSize,
            height: markSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF2D8CC),
                    Color(0xFFE7EEE5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.charcoal.withValues(alpha: 0.08),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: markSize * 0.22,
                    top: markSize * 0.2,
                    child: SizedBox(
                      width: markSize * 0.28,
                      height: markSize * 0.42,
                      child: const _ForkGlyph(),
                    ),
                  ),
                  Positioned(
                    right: markSize * 0.2,
                    top: markSize * 0.2,
                    child: Transform.rotate(
                      angle: math.pi / 10,
                      child: SizedBox(
                        width: markSize * 0.18,
                        height: markSize * 0.52,
                        child: const _SpoonGlyph(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: compact ? 12 : 18),
          Text(
            'ForkScore',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: compact ? 28 : 36,
                ),
          ),
        ],
      ),
    );
  }
}

class _ForkGlyph extends StatelessWidget {
  const _ForkGlyph();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            3,
            (_) => Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.terracotta,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                color: AppTheme.terracotta,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpoonGlyph extends StatelessWidget {
  const _SpoonGlyph();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.moss,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          flex: 6,
          child: Center(
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                color: AppTheme.moss,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
