import 'package:flutter/material.dart';

Route<T> fadeRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 500),
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: duration,
  );
}
