import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/peak_colors.dart';

class SunRays extends StatefulWidget {
  final bool active;
  final Widget child;

  const SunRays({super.key, required this.active, required this.child});

  @override
  State<SunRays> createState() => _SunRaysState();
}

class _SunRaysState extends State<SunRays> with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.active ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant SunRays oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    _reveal.animateTo(
      widget.active ? 1.0 : 0.0,
      duration: Duration(milliseconds: widget.active ? 420 : 180),
      curve: widget.active ? Curves.easeOutBack : Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_spin, _reveal]),
              builder: (context, _) => _reveal.value <= 0
                  ? const SizedBox.shrink()
                  : CustomPaint(
                      painter: _RaysPainter(
                        turn: _spin.value,
                        reveal: _reveal.value,
                      ),
                    ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _RaysPainter extends CustomPainter {
  static const _rays = 12;

  final double turn;
  final double reveal;

  const _RaysPainter({required this.turn, required this.reveal});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.longestSide * 0.72 * reveal;
    final paint = Paint()
      ..color = PeakColors.sun.withValues(alpha: 0.22 * reveal);

    const step = math.pi * 2 / _rays;
    final base = turn * step;

    for (var i = 0; i < _rays; i++) {
      final angle = base + i * step;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        )
        ..lineTo(
          center.dx + math.cos(angle + step * 0.42) * radius,
          center.dy + math.sin(angle + step * 0.42) * radius,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter oldDelegate) =>
      oldDelegate.turn != turn || oldDelegate.reveal != reveal;
}
