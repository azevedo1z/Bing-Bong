import 'package:flutter/material.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/widgets/spring_pressable.dart';

class GlassIconButton extends StatelessWidget {
  final String asset;
  final Color tint;
  final VoidCallback onTap;
  final double size;
  final double borderRadius;

  const GlassIconButton({
    super.key,
    required this.asset,
    required this.tint,
    required this.onTap,
    this.size = 56,
    this.borderRadius = Radii.lg,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final innerRadius = BorderRadius.circular(borderRadius - 5);

    return SpringPressable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: tint.withValues(alpha: 0.28),
              blurRadius: 20,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: Color(0x66000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: innerRadius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(asset, fit: BoxFit.cover),
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: innerRadius,
                          gradient: RadialGradient(
                            radius: 0.9,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                            stops: const [0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.24),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
