import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double fillAlpha;
  final double strokeAlpha;
  final EdgeInsetsGeometry? padding;
  final Color tint;
  final bool showInnerHighlight;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 24,
    this.fillAlpha = 0.08,
    this.strokeAlpha = 0.16,
    this.padding,
    this.tint = Colors.white,
    this.showInnerHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final base = tint.withValues(alpha: fillAlpha);
    final topHighlight = tint.withValues(
      alpha: (fillAlpha + 0.10).clamp(0.0, 1.0),
    );
    final bottomHint = tint.withValues(
      alpha: (fillAlpha + 0.02).clamp(0.0, 1.0),
    );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: showInnerHighlight
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [topHighlight, base, bottomHint],
                    stops: const [0.0, 0.55, 1.0],
                  )
                : LinearGradient(colors: [base, base]),
            border: Border.all(
              color: Colors.white.withValues(alpha: strokeAlpha),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
