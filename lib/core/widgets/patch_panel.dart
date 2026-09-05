import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../painting/dashes.dart';
import '../theme/dimens.dart';
import '../theme/peak_colors.dart';
import 'sink_gesture.dart';

class PatchPanel extends StatelessWidget {
  final Widget child;
  final Color fill;
  final BorderRadius borderRadius;
  final double depth;
  final bool stitched;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const PatchPanel({
    super.key,
    required this.child,
    this.fill = AppColors.surface,
    this.borderRadius = const BorderRadius.all(Radius.circular(Radii.lg)),
    this.depth = Depths.sticker,
    this.stitched = false,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return _surface(0);

    return SinkGesture(
      onTap: onTap,
      depth: depth,
      child: child,
      builder: (context, sink, child) => _surface(sink, child),
    );
  }

  Widget _surface(double sink, [Widget? cached]) {
    final surface = DecoratedBox(
      decoration: patchDecoration(
        fill: fill,
        borderRadius: borderRadius,
        depth: depth - sink,
      ),
      child: stitched
          ? CustomPaint(
              foregroundPainter: _StitchPainter(borderRadius: borderRadius),
              child: _padded(cached),
            )
          : _padded(cached),
    );

    if (sink == 0) return surface;
    return Transform.translate(offset: Offset(0, sink), child: surface);
  }

  Widget _padded(Widget? cached) =>
      Padding(padding: padding ?? EdgeInsets.zero, child: cached ?? child);
}

BoxDecoration patchDecoration({
  required Color fill,
  required BorderRadius borderRadius,
  required double depth,
  Color line = AppColors.line,
}) {
  return BoxDecoration(
    color: fill,
    borderRadius: borderRadius,
    border: Border.all(color: line, width: Strokes.ink),
    boxShadow: [
      if (depth > 0)
        BoxShadow(color: line, offset: Offset(0, depth), blurRadius: 0),
      if (depth >= Depths.floating)
        BoxShadow(
          color: line.withValues(alpha: 0.28),
          offset: Offset(0, depth * 2),
          blurRadius: 26,
          spreadRadius: -10,
        ),
    ],
  );
}

class _StitchPainter extends CustomPainter {
  static const _inset = 7.0;
  static const _dash = 6.0;
  static const _gap = 5.0;

  final BorderRadius borderRadius;

  const _StitchPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = Strokes.hair
      ..strokeCap = StrokeCap.round
      ..color = PeakColors.ink.withValues(alpha: 0.32);

    canvas.drawPath(
      dashPath(Path()..addRRect(_inner(size)), dash: _dash, gap: _gap),
      paint,
    );
  }

  RRect _inner(Size size) {
    Radius shrink(Radius radius) => Radius.elliptical(
      math.max(0, radius.x - _inset),
      math.max(0, radius.y - _inset),
    );

    return RRect.fromRectAndCorners(
      (Offset.zero & size).deflate(_inset),
      topLeft: shrink(borderRadius.topLeft),
      topRight: shrink(borderRadius.topRight),
      bottomLeft: shrink(borderRadius.bottomLeft),
      bottomRight: shrink(borderRadius.bottomRight),
    );
  }

  @override
  bool shouldRepaint(_StitchPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius;
}
