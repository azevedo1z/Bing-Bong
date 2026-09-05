import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/audio_constants.dart';
import '../../../core/i18n/app_locale.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/theme/peak_colors.dart';
import '../../../core/widgets/badge_button.dart';
import '../../../core/widgets/sticker_text.dart';
import '../../language/presentation/language_overlay.dart';
import '../logic/character_notifier.dart';
import '../logic/character_state.dart';
import '../logic/quote_localizer.dart';
import 'widgets/about_sheet.dart';
import 'widgets/background.dart';
import 'widgets/bing_bong_widget.dart';
import 'widgets/pulsing_tap_me.dart';
import 'widgets/shockwave.dart';
import 'widgets/speech_bubble.dart';
import 'widgets/sun_rays.dart';

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
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.ground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Background(isTalking: state.isTalking),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: Insets.x5),
                  const _Title(),
                  const SizedBox(height: Insets.x5),
                  _ActionRow(
                    onImBingBong: _sayCatchphrase,
                    onAbout: () => _openAbout(context),
                  ),
                  const Spacer(),
                  _QuoteArea(state: state, locale: locale),
                  const SizedBox(height: Insets.x2),
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

  void _sayCatchphrase() {
    _shockwave.pulse();
    unawaited(
      ref.read(characterProvider.notifier).playSpecific(kCatchphraseAudio),
    );
  }

  void _openAbout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      isScrollControlled: true,
      builder: (_) => const AboutSheet(),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return StickerText(
      text: 'BING BONG',
      style: Theme.of(context).textTheme.displayLarge!,
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
        BadgeButton(
          icon: Icons.campaign_rounded,
          fill: AppColors.action,
          onTap: onImBingBong,
          semanticLabel: "I'm Bing Bong",
        ),
        const SizedBox(width: Insets.x5),
        BadgeButton(
          icon: Icons.question_mark_rounded,
          fill: AppColors.actionAlt,
          onTap: onAbout,
          semanticLabel: 'About',
        ),
      ],
    );
  }
}

class _QuoteArea extends StatelessWidget {
  static const _minHeight = 120.0;

  final CharacterState state;
  final AppLocale locale;

  const _QuoteArea({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final quoteKey = state.quoteKey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.x6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            reverseDuration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
            child: quoteKey == null
                ? PulsingTapMe(locale: locale)
                : _Quote(
                    key: ValueKey(quoteKey),
                    text: localizeQuote(quoteKey, locale),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  static const _shortQuote = 12;
  static const _mediumQuote = 28;

  final String text;

  const _Quote({super.key, required this.text});

  static double _sizeFor(String quote) {
    if (quote.length <= _shortQuote) return 34;
    if (quote.length <= _mediumQuote) return 27;
    return 22;
  }

  @override
  Widget build(BuildContext context) {
    return SpeechBubble(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineLarge!.copyWith(fontSize: _sizeFor(text)),
      ),
    );
  }
}

class _Character extends StatelessWidget {
  static const _stageSize = 360.0;
  static const _shockwaveSize = 320.0;

  final CharacterState state;
  final ShockwaveController shockwave;

  const _Character({required this.state, required this.shockwave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _stageSize,
      height: _stageSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ShockwaveLayer(controller: shockwave, size: _shockwaveSize),
          SunRays(
            active: state.isTalking,
            child: BingBongWidget(shockwave: shockwave),
          ),
        ],
      ),
    );
  }
}
