import 'package:flutter/material.dart';
import '../core/theme/peak_colors.dart';

const String kCharacterFont = 'DarumadropOne';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: PeakColors.accentCoral,
    brightness: Brightness.dark,
    surface: PeakColors.surface,
  ),
  scaffoldBackgroundColor: PeakColors.deepPurple,
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
);
