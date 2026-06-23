import 'package:flutter/material.dart';
import '../../../../core/theme/peak_colors.dart';

class ShockwaveController {
  _ShockwaveLayerState? _state;

  void pulse() => _state?._pulse();
}

class ShockwaveLayer extends StatefulWidget {
  final ShockwaveController controller;
  final double size;

  const ShockwaveLayer({super.key, required this.controller, this.size = 280});

  @override
  State<ShockwaveLayer> createState() => _ShockwaveLayerState();
}

class _ShockwaveLayerState extends State<ShockwaveLayer>
    with TickerProviderStateMixin {
  final List<AnimationController> _active = [];

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    widget.controller._state = null;
    for (final c in _active) {
      c.dispose();
    }
    super.dispose();
  }

  void _pulse() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _active.add(controller);
    controller.forward().whenComplete(() {
      if (!mounted) return;
      _active.remove(controller);
      controller.dispose();
      setState(() {});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final c in _active)
              AnimatedBuilder(
                animation: c,
                builder: (context, _) {
                  final t = Curves.easeOut.transform(c.value);
                  final diameter = widget.size * (0.55 + 0.75 * t);
                  final alpha = (1.0 - t) * 0.55;
                  return Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PeakColors.idleGlow.withValues(
                          alpha: alpha.clamp(0.0, 1.0),
                        ),
                        width: 2.5 * (1.0 - t * 0.7),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
