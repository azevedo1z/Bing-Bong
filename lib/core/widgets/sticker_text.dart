import 'package:flutter/material.dart';
import '../theme/peak_colors.dart';

class StickerText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color fill;
  final Color line;
  final double strokeWidth;
  final double depth;

  const StickerText({
    super.key,
    required this.text,
    required this.style,
    this.fill = AppColors.voice,
    this.line = AppColors.line,
    this.strokeWidth = 6,
    this.depth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      height: style.height,
      letterSpacing: style.letterSpacing,
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..color = line;

    return Padding(
      padding: EdgeInsets.only(bottom: depth),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, depth),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(text, style: base.copyWith(foreground: stroke)),
                Text(text, style: base.copyWith(color: line)),
              ],
            ),
          ),
          Text(text, style: base.copyWith(foreground: stroke)),
          Text(text, style: base.copyWith(color: fill)),
        ],
      ),
    );
  }
}
