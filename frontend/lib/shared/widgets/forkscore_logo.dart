import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
          SizedBox.square(
            dimension: resolvedMarkWidth,
            child: CustomPaint(painter: const _ForkScoreLogoPainter()),
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

class _ForkScoreLogoPainter extends CustomPainter {
  const _ForkScoreLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = math.min(size.width, size.height);
    final scale = shortestSide / 100;
    final center = Offset(size.width / 2, size.height / 2);

    final platePaint = Paint()
      ..color = AppTheme.softBlue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    platePaint.strokeWidth = 2.5 * scale;
    canvas.drawCircle(center, 47 * scale, platePaint);

    final innerPlatePaint = Paint()
      ..color = AppTheme.softBlue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * scale
      ..strokeCap = StrokeCap.round;
    _drawDashedCircle(
      canvas,
      center: center,
      radius: 40 * scale,
      dashLength: 2.2 * scale,
      gapLength: 2.2 * scale,
      paint: innerPlatePaint,
    );

    final utensilPaint = Paint()
      ..color = AppTheme.terracotta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fork = Path()
      ..moveTo(size.width * 0.36, size.height * 0.28)
      ..lineTo(size.width * 0.36, size.height * 0.45)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.50,
        size.width * 0.40,
        size.height * 0.52,
        size.width * 0.43,
        size.height * 0.52,
      )
      ..lineTo(size.width * 0.43, size.height * 0.72);
    canvas.drawPath(fork, utensilPaint);

    for (final x in [36.0, 40.5, 45.5, 50.0]) {
      canvas.drawLine(
        Offset(size.width * (x / 100), size.height * 0.28),
        Offset(size.width * (x / 100), size.height * 0.36),
        utensilPaint,
      );
    }

    final knife = Path()
      ..moveTo(size.width * 0.64, size.height * 0.28)
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.28,
        size.width * 0.56,
        size.height * 0.31,
        size.width * 0.56,
        size.height * 0.47,
      )
      ..lineTo(size.width * 0.56, size.height * 0.52)
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.52,
        size.width * 0.57,
        size.height * 0.72,
        size.width * 0.57,
        size.height * 0.72,
      );
    canvas.drawPath(knife, utensilPaint);

    canvas.drawLine(
      Offset(size.width * 0.56, size.height * 0.52),
      Offset(size.width * 0.64, size.height * 0.52),
      utensilPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.64, size.height * 0.28),
      Offset(size.width * 0.64, size.height * 0.52),
      utensilPaint,
    );
  }

  void _drawDashedCircle(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double dashLength,
    required double gapLength,
    required Paint paint,
  }) {
    final circumference = 2 * math.pi * radius;
    final step = (dashLength + gapLength) / circumference * 2 * math.pi;
    final sweep = dashLength / circumference * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (double start = 0; start < math.pi * 2; start += step) {
      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
