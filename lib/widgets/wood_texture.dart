import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Adds a subtle procedural wood-grain overlay on top of a child widget.
class WoodTexture extends StatelessWidget {
  final Widget child;
  final bool dark;
  final BorderRadius? borderRadius;

  const WoodTexture({
    super.key,
    required this.child,
    this.dark = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? BorderRadius.zero;
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          IgnorePointer(
            child: CustomPaint(painter: _WoodGrainPainter(dark: dark)),
          ),
        ],
      ),
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  final bool dark;

  const _WoodGrainPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final Paint washPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                const Color(0x330E0601),
                const Color(0x11000000),
                const Color(0x33130502),
              ]
            : [
                const Color(0x22FFFFFF),
                const Color(0x11F0CF9B),
                const Color(0x22F6D9AA),
              ],
      ).createShader(bounds);
    canvas.drawRect(bounds, washPaint);

    final math.Random random = math.Random(8);
    final Paint veinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = (dark ? const Color(0x33000000) : const Color(0x33000000))
      ..strokeWidth = size.height * 0.007;

    final Paint highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = (dark ? const Color(0x18FFE0A1) : const Color(0x229A5D2C))
      ..strokeWidth = size.height * 0.004;

    final int stripes = 10;
    for (int i = 0; i < stripes; i++) {
      final double baseX = (i / (stripes - 1)) * size.width;
      final Path path = Path()..moveTo(baseX, 0);
      for (double y = 0; y <= size.height; y += size.height / 18) {
        final double wave =
            math.sin((y / size.height * math.pi * 4) + i) *
            (size.width * 0.015);
        final double jitter = (random.nextDouble() - 0.5) * size.width * 0.01;
        path.lineTo(baseX + wave + jitter, y);
      }
      canvas.drawPath(path, veinPaint);
      if (i % 2 == 0) {
        canvas.drawPath(path, highlightPaint);
      }
    }

    final int knots = 4;
    for (int i = 0; i < knots; i++) {
      final double radius = size.width * (0.04 + random.nextDouble() * 0.04);
      final Offset center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawOval(
        Rect.fromCircle(center: center, radius: radius),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.15
          ..color = (dark ? const Color(0x22FFE0A1) : const Color(0x22C38847)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WoodGrainPainter oldDelegate) =>
      oldDelegate.dark != dark;
}
