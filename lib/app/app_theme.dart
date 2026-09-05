import 'package:flutter/material.dart';
import '../core/theme/peak_colors.dart';

const String kCharacterFont = 'DarumadropOne';

const String kUiFont = 'Nunito';

const String kLabelFont = 'Archivo';

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: PeakColors.lime,
    onPrimary: PeakColors.ink,
    secondary: PeakColors.sun,
    onSecondary: PeakColors.ink,
    error: PeakColors.emberInk,
    onError: PeakColors.paper,
    surface: PeakColors.paper,
    onSurface: PeakColors.ink,
    surfaceContainerHighest: PeakColors.canvasDeep,
    outline: PeakColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PeakColors.canvas,
    fontFamily: kUiFont,
    textTheme: _textTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

const TextTheme _textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: kCharacterFont,
    fontSize: 38,
    height: 1.0,
    letterSpacing: 1.5,
    color: AppColors.text,
  ),
  headlineLarge: TextStyle(
    fontFamily: kCharacterFont,
    fontSize: 28,
    height: 1.15,
    color: AppColors.text,
  ),
  headlineSmall: TextStyle(
    fontFamily: kCharacterFont,
    fontSize: 22,
    height: 1.2,
    letterSpacing: 4,
    color: AppColors.text,
  ),
  titleLarge: TextStyle(
    fontFamily: kUiFont,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: AppColors.text,
  ),
  bodyMedium: TextStyle(
    fontFamily: kUiFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.text,
  ),
  labelLarge: TextStyle(
    fontFamily: kLabelFont,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
    height: 1.2,
    color: AppColors.onFill,
  ),
  labelSmall: TextStyle(
    fontFamily: kUiFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textSoft,
  ),
);
