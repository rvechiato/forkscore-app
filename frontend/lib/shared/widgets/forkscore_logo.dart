import 'package:flutter/material.dart';

class ForkScoreLogo extends StatelessWidget {
  const ForkScoreLogo({
    super.key,
    this.compact = false,
    this.showWordmark = true,
    this.markWidth,
    this.wordmarkSize,
  });

  final bool compact;
  final bool showWordmark;
  final double? markWidth;
  final double? wordmarkSize;

  @override
  Widget build(BuildContext context) {
    final resolvedMarkWidth = markWidth ?? (compact ? 54.0 : 96.0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/icon_forkscore.png',
            width: resolvedMarkWidth,
            fit: BoxFit.contain,
          ),
          if (showWordmark) ...[
            SizedBox(width: compact ? 8 : 14),
            Text(
              'ForkScore',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: wordmarkSize ?? (compact ? 28 : 36),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
