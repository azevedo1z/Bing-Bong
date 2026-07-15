import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/peak_colors.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/spring_pressable.dart';

const _githubUrl = 'https://github.com/azevedo1z';

Future<void> _openGitHub() async {
  final uri = Uri.parse(_githubUrl);
  if (uri.scheme != 'https') return;
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Insets.x4, 0, Insets.x4, Insets.x3),
        child: GlassPanel(
          borderRadius: Radii.xxl,
          blurSigma: 30,
          fillAlpha: 0.10,
          strokeAlpha: 0.22,
          padding: const EdgeInsets.fromLTRB(
            Insets.x6,
            Insets.x4,
            Insets.x6,
            Insets.x7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _SheetHandle(),
              SizedBox(height: Insets.x6),
              _SheetIcon(),
              SizedBox(height: Insets.x5),
              _SheetTitle(),
              SizedBox(height: Insets.x1 + 2),
              _SheetSubtitle(),
              SizedBox(height: Insets.x6),
              _GitHubButton(),
              SizedBox(height: Insets.x4),
              _SheetFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetIcon extends StatelessWidget {
  const _SheetIcon();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Radii.xl);
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.action.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/about_icon.jpg', fit: BoxFit.cover),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.22),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
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

class _SheetTitle extends StatelessWidget {
  const _SheetTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Bing Bong',
      style: TextStyle(
        fontFamily: kCharacterFont,
        fontSize: 30,
        color: AppColors.voice,
        shadows: kTextShadows,
      ),
    );
  }
}

class _SheetSubtitle extends StatelessWidget {
  const _SheetSubtitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'A Magic 8-Ball inspired by Peak',
      style: TextStyle(
        fontSize: 13,
        letterSpacing: 0.4,
        color: PeakColors.textMuted.withValues(alpha: 0.9),
      ),
    );
  }
}

class _SheetFooter extends StatelessWidget {
  const _SheetFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tap Bing Bong and ask him anything.',
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 0.3,
        color: PeakColors.textMuted.withValues(alpha: 0.6),
      ),
    );
  }
}

class _GitHubButton extends StatelessWidget {
  const _GitHubButton();

  @override
  Widget build(BuildContext context) {
    return SpringPressable(
      onTap: _openGitHub,
      pressedScale: 0.92,
      upDuration: const Duration(milliseconds: 360),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.action,
              AppColors.action.withValues(alpha: 0.82),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.action.withValues(alpha: 0.45),
              blurRadius: 22,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.code_rounded, size: 18, color: Colors.white),
            SizedBox(width: 10),
            Text(
              '@azevedo1z',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
