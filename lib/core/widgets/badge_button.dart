import 'package:flutter/material.dart';
import '../theme/dimens.dart';
import '../theme/peak_colors.dart';
import 'patch_panel.dart';
import 'sink_gesture.dart';

class BadgeButton extends StatelessWidget {
  static const double _size = 70;

  final IconData icon;
  final Color fill;
  final VoidCallback onTap;
  final String semanticLabel;

  const BadgeButton({
    super.key,
    required this.icon,
    required this.fill,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SinkGesture(
        onTap: onTap,
        depth: Depths.button,
        child: Icon(icon, size: 32, color: AppColors.onFill),
        builder: (context, sink, child) => Transform.translate(
          offset: Offset(0, sink),
          child: Container(
            width: _size,
            height: _size,
            alignment: Alignment.center,
            decoration: patchDecoration(
              fill: fill,
              borderRadius: BorderRadius.circular(_size),
              depth: Depths.button - sink,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
