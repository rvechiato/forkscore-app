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
    final resolvedMarkWidth = markWidth ?? (compact ? 44.0 : 72.0);

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
            SizedBox(width: compact ? 12 : 20),
            Text(
              'ForkScore',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: wordmarkSize ?? (compact ? 22 : 28),
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
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

    final thinLinePaint = Paint()
      ..color = AppTheme.primaryBrand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale
      ..strokeCap = StrokeCap.round;

    // Prato ultra-fino
    canvas.drawCircle(center, 48 * scale, thinLinePaint);

    final dashPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale
      ..strokeCap = StrokeCap.round;

    _drawDashedCircle(
      canvas,
      center: center,
      radius: 40 * scale,
      dashLength: 4 * scale,
      gapLength: 4 * scale,
      paint: dashPaint,
    );

    // Garfo e faca (linhas super finas e geométricas)
    final utensilPaint = Paint()
      ..color = AppTheme.primaryBrand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round;

    // Garfo simplificado e elegante
    final forkX = size.width * 0.40;
    canvas.drawLine(
      Offset(forkX, size.height * 0.25),
      Offset(forkX, size.height * 0.75),
      utensilPaint,
    );
    canvas.drawLine(
      Offset(forkX - 4 * scale, size.height * 0.25),
      Offset(forkX - 4 * scale, size.height * 0.45),
      utensilPaint,
    );
    canvas.drawLine(
      Offset(forkX + 4 * scale, size.height * 0.25),
      Offset(forkX + 4 * scale, size.height * 0.45),
      utensilPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(forkX, size.height * 0.45),
        radius: 4 * scale,
      ),
      0,
      math.pi,
      false,
      utensilPaint,
    );

    // Faca simplificada e elegante
    final knifeX = size.width * 0.60;
    canvas.drawLine(
      Offset(knifeX, size.height * 0.25),
      Offset(knifeX, size.height * 0.75),
      utensilPaint,
    );
    final knifeBlade = Path()
      ..moveTo(knifeX, size.height * 0.25)
      ..lineTo(knifeX + 6 * scale, size.height * 0.35)
      ..lineTo(knifeX, size.height * 0.50);
    canvas.drawPath(knifeBlade, utensilPaint);
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
