import 'package:flutter/material.dart';

import '../../../theme/app_tokens.dart';

class DashedBorder extends StatelessWidget {
  const DashedBorder({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedBorderPainter(
      Theme.of(context).extension<AppThemeExtras>()!.outline,
    ),
    child: Center(child: child),
  );
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = AppStroke.base
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadius.sm),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + AppSpace.xs;
        final end = next < metric.length ? next : metric.length;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + AppSpace.xxs;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
