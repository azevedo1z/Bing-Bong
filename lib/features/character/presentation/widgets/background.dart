import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/peak_colors.dart';

class Background extends StatefulWidget {
  final bool isTalking;

  const Background({super.key, required this.isTalking});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> with TickerProviderStateMixin {
  late final AnimationController _clouds;
  late final AnimationController _ridge;

  @override
  void initState() {
    super.initState();
    _clouds = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 44),
    )..repeat();
    _ridge = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
  }

  @override
  void dispose() {
    _clouds.dispose();
    _ridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface,
                AppColors.ground,
                AppColors.groundDeep,
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          opacity: widget.isTalking ? 1.0 : 0.0,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.05),
                radius: 0.95,
                colors: [Color(0x33F58F2B), Color(0x00F58F2B)],
              ),
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_clouds, _ridge]),
            builder: (context, _) => CustomPaint(
              painter: _ParallaxPainter(
                clouds: _clouds.value,
                ridge: _ridge.value,
              ),
            ),
          ),
        ),
        const RepaintBoundary(child: CustomPaint(painter: _GrainPainter())),
      ],
    );
  }
}

class _ParallaxPainter extends CustomPainter {
  final double clouds;
  final double ridge;

  const _ParallaxPainter({required this.clouds, required this.ridge});

  @override
  void paint(Canvas canvas, Size size) {
    _paintClouds(canvas, size);

    _paintRidge(canvas, size, clouds, 0.18, PeakColors.moss, 0.28);
    _paintRidge(canvas, size, ridge, 0.11, PeakColors.mossDeep, 0.42);
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.surface.withValues(alpha: 0.6);
    const shapes = [
      (x: 0.12, y: 0.10, r: 34.0),
      (x: 0.68, y: 0.17, r: 26.0),
      (x: 0.42, y: 0.06, r: 20.0),
    ];

    for (final shape in shapes) {
      final drift = (clouds + shape.x) % 1.0;
      final cx = drift * (size.width + 220) - 110;
      final cy = size.height * shape.y;

      canvas.drawCircle(Offset(cx, cy), shape.r, paint);
      canvas.drawCircle(
        Offset(cx + shape.r * 0.9, cy + shape.r * 0.2),
        shape.r * 0.72,
        paint,
      );
      canvas.drawCircle(
        Offset(cx - shape.r * 0.85, cy + shape.r * 0.25),
        shape.r * 0.62,
        paint,
      );
    }
  }

  void _paintRidge(
    Canvas canvas,
    Size size,
    double t,
    double heightRatio,
    Color color,
    double alpha,
  ) {
    final paint = Paint()..color = color.withValues(alpha: alpha);
    final band = size.height * heightRatio;
    final top = size.height - band;
    const humps = 7;
    final span = size.width / humps;
    final shift = -t * span * 2;

    final path = Path()..moveTo(shift - span, size.height);

    for (var i = -1; i <= humps + 1; i++) {
      final x = shift + i * span;
      path.quadraticBezierTo(x + span * 0.5, top, x + span, size.height);
    }
    path
      ..lineTo(size.width + span * 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParallaxPainter oldDelegate) =>
      oldDelegate.clouds != clouds || oldDelegate.ridge != ridge;
}

class _GrainPainter extends CustomPainter {
  static const _dots = 1400;

  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint()..color = PeakColors.ink.withValues(alpha: 0.05);

    for (var i = 0; i < _dots; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 1.1 + 0.3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => false;
}
