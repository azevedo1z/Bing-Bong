import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpringPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration downDuration;
  final Duration upDuration;
  final bool enableHaptics;

  const SpringPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.88,
    this.downDuration = const Duration(milliseconds: 90),
    this.upDuration = const Duration(milliseconds: 380),
    this.enableHaptics = true,
  });

  @override
  State<SpringPressable> createState() => _SpringPressableState();
}

class _SpringPressableState extends State<SpringPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.upDuration,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDown() {
    if (widget.enableHaptics) HapticFeedback.selectionClick();
    _controller.animateTo(
      0.0,
      duration: widget.downDuration,
      curve: Curves.easeOut,
    );
  }

  void _onRelease() {
    _controller.animateTo(
      1.0,
      duration: widget.upDuration,
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => _onDown() : null,
      onTapUp: enabled ? (_) => _onRelease() : null,
      onTapCancel: enabled ? _onRelease : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale =
              widget.pressedScale +
              _controller.value * (1.0 - widget.pressedScale);
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.child,
      ),
    );
  }
}
