import 'package:flutter/material.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/peak_colors.dart';

const double _tailHeight = 22;
const double _tailWidth = 34;

const double _tailLean = 4;

const double _tailOverlap = 2;

const double _depth = Depths.floating;

class SpeechBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SpeechBubble({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Insets.x5,
      vertical: Insets.x4,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _BubblePainter(),
      child: Padding(
        padding: padding.add(
          const EdgeInsets.only(bottom: _tailHeight + _depth),
        ),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = _outline(size);

    canvas
      ..drawPath(
        path.shift(const Offset(0, _depth)),
        Paint()..color = AppColors.line,
      )
      ..drawPath(path, Paint()..color = AppColors.surface)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = Strokes.ink
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.line,
      );
  }

  Path _outline(Size size) {
    const half = Strokes.ink / 2;
    final bodyBottom = size.height - _tailHeight - _depth - half;

    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(half, half, size.width - half, bodyBottom),
          const Radius.circular(Radii.lg),
        ),
      );

    final centerX = size.width / 2;
    final tail = Path()
      ..moveTo(centerX - _tailWidth / 2, bodyBottom - _tailOverlap)
      ..lineTo(centerX - _tailLean, bodyBottom + _tailHeight)
      ..lineTo(centerX + _tailWidth / 2, bodyBottom - _tailOverlap)
      ..close();

    return Path.combine(PathOperation.union, body, tail);
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => false;
}
