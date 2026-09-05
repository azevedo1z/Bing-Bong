import 'package:flutter/material.dart';

abstract final class PeakColors {
  static const canvas = Color(0xFFF0E3C8);
  static const canvasDeep = Color(0xFFE4D3B0);
  static const paper = Color(0xFFFAF3E2);

  static const ink = Color(0xFF14120E);
  static const inkSoft = Color(0xFF4A4436);

  static const lime = Color(0xFFC7E24B);
  static const moss = Color(0xFF7FA320);
  static const mossDeep = Color(0xFF4A5D14);
  static const sun = Color(0xFFF58F2B);
  static const ember = Color(0xFFE2402F);
  static const sky = Color(0xFF2E9BD6);

  static const emberInk = Color(0xFFB22D1E);
  static const skyInk = Color(0xFF175E88);
}

abstract final class AppColors {
  static const ground = PeakColors.canvas;
  static const groundDeep = PeakColors.canvasDeep;
  static const surface = PeakColors.paper;

  static const line = PeakColors.ink;
  static const text = PeakColors.ink;
  static const textSoft = PeakColors.mossDeep;
  static const onFill = PeakColors.ink;

  static const voice = PeakColors.lime;
  static const action = PeakColors.lime;
  static const actionAlt = PeakColors.sun;

  static const scrim = Color(0x8C14120E);
}
