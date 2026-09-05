import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/peak_colors.dart';
import '../../../../core/widgets/patch_panel.dart';
import '../../../../core/widgets/pill_button.dart';

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
    return PatchPanel(
      depth: Depths.floating,
      stitched: true,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Insets.x5,
            Insets.x4,
            Insets.x5,
            Insets.x5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _SheetHandle(),
              SizedBox(height: Insets.x5),
              _SheetIcon(),
              SizedBox(height: Insets.x4),
              _SheetTitle(),
              SizedBox(height: Insets.x1),
              _MutedLine('A Magic 8-Ball inspired by Peak'),
              SizedBox(height: Insets.x5),
              _GitHubButton(),
              SizedBox(height: Insets.x4),
              _SheetCredits(),
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
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
    );
  }
}

class _SheetIcon extends StatelessWidget {
  const _SheetIcon();

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(Radii.md));

    return DecoratedBox(
      decoration: patchDecoration(
        fill: AppColors.surface,
        borderRadius: radius,
        depth: Depths.sticker,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Strokes.ink),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(Radii.md - Strokes.ink),
          ),
          child: Image.asset(
            'assets/images/about_icon.jpg',
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle();

  @override
  Widget build(BuildContext context) {
    return Text('Bing Bong', style: Theme.of(context).textTheme.headlineLarge);
  }
}

class _MutedLine extends StatelessWidget {
  final String text;

  const _MutedLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: AppColors.textSoft),
    );
  }
}

class _SheetCredits extends StatelessWidget {
  const _SheetCredits();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _MutedLine('Tap Bing Bong and ask him anything.'),
        const SizedBox(height: Insets.x1),
        Text(
          '3D model by OFFDucky3D',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _GitHubButton extends StatelessWidget {
  const _GitHubButton();

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: '@azevedo1z',
      icon: Icons.code_rounded,
      onTap: _openGitHub,
    );
  }
}
