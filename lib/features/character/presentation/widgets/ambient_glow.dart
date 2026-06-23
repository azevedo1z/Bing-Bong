import 'package:flutter/material.dart';
import '../../../../core/theme/peak_colors.dart';

class AmbientGlow extends StatefulWidget {
  final bool active;
  final Widget child;

  const AmbientGlow({super.key, required this.active, required this.child});

  @override
  State<AmbientGlow> createState() => _AmbientGlowState();
}

class _AmbientGlowState extends State<AmbientGlow>
    with TickerProviderStateMixin {
  late final AnimationController _breath;
  late final AnimationController _activeAnim;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _activeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: widget.active ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant AmbientGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      _activeAnim.animateTo(
        widget.active ? 1.0 : 0.0,
        duration: Duration(milliseconds: widget.active ? 600 : 500),
        curve: widget.active ? Curves.easeOut : Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _activeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breath, _activeAnim]),
      builder: (context, child) {
        final activeT = _activeAnim.value;
        final breathT = Curves.easeInOut.transform(_breath.value);
        final blur = (60 + 40 * breathT) * activeT;
        final spread = (12 + 16 * breathT) * activeT;
        final warmAlpha = ((0.32 + 0.18 * breathT) * activeT).clamp(0.0, 1.0);
        final coolAlpha = ((0.18 + 0.12 * breathT) * activeT).clamp(0.0, 1.0);

        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: activeT == 0
                ? null
                : [
                    BoxShadow(
                      color: PeakColors.talkGlow.withValues(alpha: warmAlpha),
                      blurRadius: blur,
                      spreadRadius: spread,
                    ),
                    BoxShadow(
                      color: PeakColors.idleGlow.withValues(alpha: coolAlpha),
                      blurRadius: blur * 0.7,
                      spreadRadius: spread * 0.55,
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
