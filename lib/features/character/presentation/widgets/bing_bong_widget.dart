import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/character_notifier.dart';
import 'bing_bong_model.dart';
import 'shockwave.dart';

class BingBongWidget extends ConsumerStatefulWidget {
  final ShockwaveController? shockwave;

  const BingBongWidget({super.key, this.shockwave});

  @override
  ConsumerState<BingBongWidget> createState() => _BingBongWidgetState();
}

class _BingBongWidgetState extends ConsumerState<BingBongWidget>
    with TickerProviderStateMixin {
  static const double _modelSize = 280;
  static const double _dragSensitivity = 0.011;

  late final AnimationController _floatController;
  late final AnimationController _breathController;
  late final AnimationController _bounceController;
  late final AnimationController _wobbleController;

  late final CurvedAnimation _floatCurve;
  late final Animation<double> _floatAnim;

  late final CurvedAnimation _breathAnim;
  late final Animation<double> _scaleY;
  late final Animation<double> _scaleX;

  final CharacterOrbitController _orbit = CharacterOrbitController();
  late final Widget _modelViewport;

  @override
  void initState() {
    super.initState();

    _modelViewport = SizedBox(
      width: _modelSize,
      height: _modelSize,
      child: BingBongModel(orbit: _orbit),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _floatCurve = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(_floatCurve);

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _breathAnim = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );

    _scaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.88,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.88,
          end: 1.20,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.20,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 64,
      ),
    ]).animate(_bounceController);

    _scaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.10,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.10,
          end: 0.86,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.86,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 64,
      ),
    ]).animate(_bounceController);

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _floatCurve.dispose();
    _breathAnim.dispose();
    _floatController.dispose();
    _breathController.dispose();
    _bounceController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    HapticFeedback.mediumImpact();
    widget.shockwave?.pulse();

    _bounceController.forward(from: 0);
    _wobbleController.forward(from: 0);

    await ref.read(characterProvider.notifier).onTap();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _orbit.rotate(
      details.delta.dx * _dragSensitivity,
      -details.delta.dy * _dragSensitivity,
    );
  }

  void _onPanEnd(DragEndDetails details) => _orbit.release();

  double _wobbleRad(double w) {
    if (w == 0) return 0;
    final decay = math.pow(1 - w, 1.8).toDouble();
    return math.sin(w * math.pi * 3.0) * 0.045 * decay;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatController,
          _breathController,
          _bounceController,
          _wobbleController,
        ]),
        builder: (context, child) {
          final breathT = _breathAnim.value;
          final breathY = 1.0 + breathT * 0.018;
          final breathX = 1.0 - breathT * 0.012;

          final sy = _scaleY.value * breathY;
          final sx = _scaleX.value * breathX;

          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: Transform.rotate(
              angle: _wobbleRad(_wobbleController.value),
              child: Transform.scale(
                scaleX: sx,
                scaleY: sy,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
        child: _modelViewport,
      ),
    );
  }
}
