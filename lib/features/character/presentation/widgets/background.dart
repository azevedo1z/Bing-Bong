import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/peak_colors.dart';

class Background extends StatefulWidget {
  final bool isTalking;
  const Background({super.key, required this.isTalking});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> with TickerProviderStateMixin {
  late final AnimationController _leakA;
  late final AnimationController _leakB;

  @override
  void initState() {
    super.initState();
    _leakA = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();
    _leakB = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 17),
    )..repeat();
  }

  @override
  void dispose() {
    _leakA.dispose();
    _leakB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Image.asset(
            'assets/images/background.webp',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [PeakColors.midPurple, PeakColors.deepPurple],
                ),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.05),
              radius: 1.1,
              colors: [
                PeakColors.deepPurple.withValues(
                  alpha: widget.isTalking ? 0.05 : 0.22,
                ),
                PeakColors.deepPurple.withValues(alpha: 0.72),
                PeakColors.vignetteEdge.withValues(alpha: 0.92),
              ],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOut,
          opacity: widget.isTalking ? 0.22 : 0.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.05),
                radius: 0.9,
                colors: [
                  PeakColors.talkGlow.withValues(alpha: 0.55),
                  PeakColors.talkGlow.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        _LightLeak(
          controller: _leakA,
          color: PeakColors.warmLeak,
          reverse: false,
        ),
        _LightLeak(
          controller: _leakB,
          color: PeakColors.coolLeak,
          reverse: true,
        ),
      ],
    );
  }
}

class _LightLeak extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final bool reverse;

  const _LightLeak({
    required this.controller,
    required this.color,
    required this.reverse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = reverse ? 1.0 - controller.value : controller.value;
        final dx = (reverse ? -0.8 : 0.8) + (reverse ? 1.4 : -1.4) * t;
        final dy = 1.2 - 2.4 * t;
        return Positioned(
          left: MediaQuery.of(context).size.width * (0.5 + dx * 0.35) - 140,
          top: MediaQuery.of(context).size.height * (0.5 + dy * 0.35) - 140,
          child: IgnorePointer(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.16),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
