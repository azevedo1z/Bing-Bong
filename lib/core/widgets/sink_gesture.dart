import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/dimens.dart';

class SinkGesture extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, double sink, Widget child)
  builder;
  final VoidCallback? onTap;
  final double depth;
  final bool enableHaptics;

  const SinkGesture({
    super.key,
    required this.child,
    required this.builder,
    this.onTap,
    this.depth = Depths.sticker,
    this.enableHaptics = true,
  });

  @override
  State<SinkGesture> createState() => _SinkGestureState();
}

class _SinkGestureState extends State<SinkGesture>
    with SingleTickerProviderStateMixin {
  static const _down = Duration(milliseconds: 90);
  static const _up = Duration(milliseconds: 380);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _up);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press() {
    if (widget.enableHaptics) HapticFeedback.selectionClick();
    _controller.animateTo(1.0, duration: _down, curve: Curves.easeOut);
  }

  void _release() =>
      _controller.animateTo(0.0, duration: _up, curve: Curves.elasticOut);

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => _press() : null,
      onTapUp: enabled ? (_) => _release() : null,
      onTapCancel: enabled ? _release : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            widget.builder(context, _controller.value * widget.depth, child!),
        child: widget.child,
      ),
    );
  }
}
