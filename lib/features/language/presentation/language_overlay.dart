import 'package:flutter/material.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/theme/peak_colors.dart';
import '../../../core/widgets/patch_panel.dart';

class LanguageOverlay extends StatefulWidget {
  static const double _panelMaxWidth = 340;

  final ValueChanged<AppLocale> onSelect;

  const LanguageOverlay({super.key, required this.onSelect});

  @override
  State<LanguageOverlay> createState() => _LanguageOverlayState();
}

class _LanguageOverlayState extends State<LanguageOverlay>
    with SingleTickerProviderStateMixin {
  static const double _span = 0.55;

  late final AnimationController _entrance;
  late final CurvedAnimation _panelIn;
  late final CurvedAnimation _englishIn;
  late final CurvedAnimation _portugueseIn;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );

    _panelIn = _step(0.0);
    _englishIn = _step(0.20);
    _portugueseIn = _step(0.30);
    _entrance.forward();
  }

  CurvedAnimation _step(double begin) {
    assert(begin + _span <= 1.0, 'a entrada tem de caber no controlador');
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(begin, begin + _span, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _panelIn.dispose();
    _englishIn.dispose();
    _portugueseIn.dispose();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ModalBarrier(dismissible: false, color: AppColors.scrim),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(Insets.x6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LanguageOverlay._panelMaxWidth,
              ),
              child: _pop(
                _panelIn,
                PatchPanel(
                  depth: Depths.floating,
                  stitched: true,
                  padding: const EdgeInsets.all(Insets.x5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LANGUAGE',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: Insets.x5),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _pop(
                                _englishIn,
                                _LanguageBadge(
                                  code: 'EN',
                                  label: 'English',
                                  fill: AppColors.action,
                                  onTap: () => widget.onSelect(AppLocale.en),
                                ),
                              ),
                            ),
                            const SizedBox(width: Insets.x3),
                            Expanded(
                              child: _pop(
                                _portugueseIn,
                                _LanguageBadge(
                                  code: 'PT',
                                  label: 'Português',
                                  fill: AppColors.actionAlt,
                                  onTap: () => widget.onSelect(AppLocale.pt),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _pop(Animation<double> animation, Widget child) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(scale: animation, child: child),
  );
}

class _LanguageBadge extends StatelessWidget {
  final String code;
  final String label;
  final Color fill;
  final VoidCallback onTap;

  const _LanguageBadge({
    required this.code,
    required this.label,
    required this.fill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return PatchPanel(
      fill: fill,
      depth: Depths.button,
      borderRadius: BorderRadius.circular(Radii.md),
      padding: const EdgeInsets.symmetric(vertical: Insets.x4),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: theme.labelLarge!.copyWith(fontSize: 26, letterSpacing: 2),
          ),
          const SizedBox(height: Insets.x1),
          Text(
            label,
            style: theme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
