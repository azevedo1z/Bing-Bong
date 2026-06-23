import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/theme/peak_colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/spring_pressable.dart';

class LanguageOverlay extends StatelessWidget {
  static const double _panelMaxWidth = 320;

  final ValueChanged<AppLocale> onSelect;

  const LanguageOverlay({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ModalBarrier(dismissible: false, color: Color(0x99080312)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(Insets.x8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _panelMaxWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Radii.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: PeakColors.talkGlow.withValues(alpha: 0.20),
                      blurRadius: 46,
                      spreadRadius: 2,
                      offset: const Offset(-6, -10),
                    ),
                    BoxShadow(
                      color: PeakColors.accentCyan.withValues(alpha: 0.20),
                      blurRadius: 46,
                      spreadRadius: 2,
                      offset: const Offset(8, 12),
                    ),
                  ],
                ),
                child: GlassPanel(
                  borderRadius: Radii.xxl,
                  blurSigma: 30,
                  fillAlpha: 0.10,
                  strokeAlpha: 0.22,
                  padding: const EdgeInsets.all(Insets.x6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'LANGUAGE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: kCharacterFont,
                          fontSize: 17,
                          color: PeakColors.textPrimary,
                          shadows: kTextShadows,
                        ),
                      ),
                      const SizedBox(height: Insets.x5),
                      _LanguageButton(
                        label: 'English',
                        code: 'EN',
                        onTap: () => onSelect(AppLocale.en),
                      ),
                      const SizedBox(height: Insets.x3),
                      _LanguageButton(
                        label: 'Português',
                        code: 'PT',
                        onTap: () => onSelect(AppLocale.pt),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final String code;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpringPressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.x5,
          vertical: Insets.x4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.md),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.045),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: PeakColors.textPrimary,
                  shadows: kTextShadows,
                ),
              ),
            ),
            _CodeChip(code: code),
          ],
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  final String code;

  const _CodeChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.x2,
        vertical: Insets.x1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sm),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: PeakColors.textPrimary,
        ),
      ),
    );
  }
}
