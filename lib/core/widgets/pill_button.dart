import 'package:flutter/material.dart';
import '../theme/dimens.dart';
import '../theme/peak_colors.dart';
import 'patch_panel.dart';
import 'sink_gesture.dart';

class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color fill;
  final Color foreground;
  final VoidCallback onTap;

  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.fill = AppColors.line,
    this.foreground = AppColors.ground,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: Insets.x2),
        ],
        Text(
          label.toUpperCase(),
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: foreground),
        ),
      ],
    );

    return Semantics(
      button: true,
      label: label,
      child: SinkGesture(
        onTap: onTap,
        depth: Depths.button,
        child: content,
        builder: (context, sink, child) => Transform.translate(
          offset: Offset(0, sink),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.x5,
              vertical: Insets.x3,
            ),
            decoration: patchDecoration(
              fill: fill,
              borderRadius: BorderRadius.circular(Radii.pill),
              depth: Depths.button - sink,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
