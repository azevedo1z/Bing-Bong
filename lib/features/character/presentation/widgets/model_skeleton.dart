import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/painting/dashes.dart';
import '../../../../core/theme/peak_colors.dart';

class ModelSkeleton extends StatefulWidget {
  const ModelSkeleton({super.key});

  @override
  State<ModelSkeleton> createState() => _ModelSkeletonState();
}

class _ModelSkeletonState extends State<ModelSkeleton>
    with SingleTickerProviderStateMixin {
  static const double _tiltDegrees = 2;

  static const double _radiansPerDegree = math.pi / 180;

  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_breath.value);
        return Transform.rotate(
          angle: (-_tiltDegrees + 2 * _tiltDegrees * t) * _radiansPerDegree,
          child: Transform.scale(
            scale: 1.0 + t * 0.07,
            child: const CustomPaint(painter: _SilhouettePainter()),
          ),
        );
      },
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..addOval(Rect.fromLTWH(w * 0.13, h * 0.14, w * 0.74, h * 0.44));

    final limbs = Path();
    const legs = [
      (from: 0.30, to: 0.10),
      (from: 0.44, to: 0.30),
      (from: 0.58, to: 0.72),
      (from: 0.72, to: 0.92),
    ];
    for (final leg in legs) {
      limbs
        ..moveTo(w * leg.from, h * 0.55)
        ..quadraticBezierTo(w * leg.from, h * 0.80, w * leg.to, h * 0.93);
    }

    limbs
      ..moveTo(w * 0.28, h * 0.20)
      ..quadraticBezierTo(w * 0.18, h * 0.08, w * 0.24, h * 0.02);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.line.withValues(alpha: 0.45);

    canvas
      ..drawPath(dashPath(body, dash: 11, gap: 8), paint)
      ..drawPath(dashPath(limbs, dash: 11, gap: 8), paint);
  }

  @override
  bool shouldRepaint(_SilhouettePainter oldDelegate) => false;
}
