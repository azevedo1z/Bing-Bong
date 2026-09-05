import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/peak_colors.dart';

class ShockwaveController {
  _ShockwaveLayerState? _state;

  void pulse() => _state?._pulse();
}

class ShockwaveLayer extends StatefulWidget {
  final ShockwaveController controller;
  final double size;

  const ShockwaveLayer({super.key, required this.controller, this.size = 280});

  @override
  State<ShockwaveLayer> createState() => _ShockwaveLayerState();
}

class _ShockwaveLayerState extends State<ShockwaveLayer>
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 420);

  final List<AnimationController> _active = [];

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    widget.controller._state = null;
    for (final controller in _active) {
      controller
        ..stop()
        ..dispose();
    }
    super.dispose();
  }

  void _pulse() {
    final controller = AnimationController(vsync: this, duration: _duration);
    _active.add(controller);
    controller.forward().whenComplete(() {
      if (!mounted) return;
      _active.remove(controller);
      controller.dispose();
      setState(() {});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final controller in _active)
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) =>
                    CustomPaint(painter: _BurstPainter(controller.value)),
              ),
          ],
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  static const _points = 11;
  static const _innerRatio = 0.62;
  static const _fadeFrom = 0.7;

  final double progress;

  const _BurstPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutQuart.transform(progress);

    final fade = progress < _fadeFrom
        ? 1.0
        : 1.0 - (progress - _fadeFrom) / (1 - _fadeFrom);

    final outer = size.width * 0.5 * (0.4 + 0.9 * t);
    final center = size.center(Offset.zero);
    final path = Path();

    for (var i = 0; i < _points * 2; i++) {
      final radius = i.isEven ? outer : outer * _innerRatio;
      final angle = math.pi * i / _points - math.pi / 2;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = Strokes.ink
        ..strokeJoin = StrokeJoin.round
        ..color = PeakColors.ink.withValues(
          alpha: (fade * 0.9).clamp(0.0, 1.0),
        ),
    );
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
