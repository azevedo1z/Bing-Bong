import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_theme.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/theme/peak_colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../logic/character_notifier.dart';
import '../logic/character_state.dart';
import '../logic/quote_localizer.dart';
import 'widgets/about_sheet.dart';
import 'widgets/ambient_glow.dart';
import 'widgets/background.dart';
import 'widgets/bing_bong_widget.dart';
import '../../language/presentation/language_overlay.dart';
import 'widgets/glass_icon_button.dart';
import 'widgets/im_bing_bong_button.dart';
import 'widgets/pulsing_tap_me.dart';
import 'widgets/shockwave.dart';

class CharacterPage extends ConsumerStatefulWidget {
  const CharacterPage({super.key});

  @override
  ConsumerState<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends ConsumerState<CharacterPage> {
  final ShockwaveController _shockwave = ShockwaveController();
  AppLocale? _locale;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterProvider);
    final locale = _locale ?? AppLocale.en;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: PeakColors.deepPurple,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Background(isTalking: state.isTalking),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: Insets.x5),
                  const _Title(),
                  const SizedBox(height: Insets.x4),
                  _ActionRow(
                    onImBingBong: () {
                      _shockwave.pulse();
                      ref
                          .read(characterProvider.notifier)
                          .playSpecific('audio/im bing bong.mp3');
                    },
                    onAbout: () => _openAbout(context),
                  ),
                  const Spacer(),
                  _QuoteArea(state: state, locale: locale),
                  const SizedBox(height: Insets.x7),
                  _Character(state: state, shockwave: _shockwave),
                  const Spacer(),
                ],
              ),
            ),
            if (_locale == null)
              LanguageOverlay(
                onSelect: (selected) => setState(() => _locale = selected),
              ),
          ],
        ),
      ),
    );
  }

  void _openAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (_) => const AboutSheet(),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'BING BONG',
          style: TextStyle(
            fontFamily: kCharacterFont,
            fontSize: 34,
            letterSpacing: 6,
            color: AppColors.voice,
            shadows: kTextShadows,
          ),
        ),
        const SizedBox(height: Insets.x1 + 2),
        Container(
          width: 44,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.0),
                AppColors.action.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback onImBingBong;
  final VoidCallback onAbout;

  const _ActionRow({required this.onImBingBong, required this.onAbout});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImBingBongButton(onTap: onImBingBong),
        const SizedBox(width: Insets.x5),
        GlassIconButton(
          asset: 'assets/images/about_icon.jpg',
          tint: AppColors.actionAlt,
          onTap: onAbout,
        ),
      ],
    );
  }
}

class _QuoteArea extends StatelessWidget {
  final CharacterState state;
  final AppLocale locale;

  const _QuoteArea({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.x7),
      child: SizedBox(
        height: 110,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: state.isTalking
                ? GlassPanel(
                    key: ValueKey(state.quoteKey),
                    borderRadius: Radii.xl,
                    blurSigma: 16,
                    fillAlpha: 0.06,
                    strokeAlpha: 0.14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.x5,
                      vertical: Insets.x3,
                    ),
                    child: Text(
                      localizeQuote(state.quoteKey, locale),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: kCharacterFont,
                        fontSize: 26,
                        height: 1.2,
                        color: AppColors.quote,
                        fontStyle: FontStyle.italic,
                        shadows: kTextShadows,
                      ),
                    ),
                  )
                : PulsingTapMe(locale: locale),
          ),
        ),
      ),
    );
  }
}

class _Character extends StatelessWidget {
  final CharacterState state;
  final ShockwaveController shockwave;

  const _Character({required this.state, required this.shockwave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 360,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ShockwaveLayer(controller: shockwave, size: 320),
          AmbientGlow(
            active: state.isTalking,
            child: BingBongWidget(shockwave: shockwave),
          ),
        ],
      ),
    );
  }
}
