import 'package:flutter/material.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/theme/peak_colors.dart';

class PulsingTapMe extends StatefulWidget {
  final AppLocale locale;

  const PulsingTapMe({super.key, required this.locale});

  @override
  State<PulsingTapMe> createState() => _PulsingTapMeState();
}

class _PulsingTapMeState extends State<PulsingTapMe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.locale == AppLocale.pt ? 'toque em mim' : 'tap me';
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Opacity(
          opacity: 0.55 + t * 0.45,
          child: Transform.scale(scale: 0.98 + t * 0.04, child: child),
        );
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kCharacterFont,
            fontSize: 32,
            letterSpacing: 8,
            color: PeakColors.textPrimary.withValues(alpha: 0.92),
            shadows: kTextShadows,
          ),
        ),
      ),
    );
  }
}
