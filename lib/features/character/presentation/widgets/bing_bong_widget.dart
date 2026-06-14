import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thermion_flutter/thermion_flutter.dart';

import '../../logic/character_notifier.dart';
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

  late final AnimationController _floatController;
  late final AnimationController _breathController;
  late final AnimationController _bounceController;
  late final AnimationController _wobbleController;

  late final Animation<double> _floatAnim;
  late final Animation<double> _breathAnim;
  late final Animation<double> _scaleY;
  late final Animation<double> _scaleX;

  final Widget _modelViewport = const SizedBox(
    width: _modelSize,
    height: _modelSize,
    child: BingBongModel(),
  );

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _breathAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );

    _scaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.88)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.20)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.20, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 64,
      ),
    ]).animate(_bounceController);

    _scaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.10)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 0.86)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.86, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
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

  double _wobbleRad(double w) {
    if (w == 0) return 0;
    final decay = math.pow(1 - w, 1.8).toDouble();
    return math.sin(w * math.pi * 3.0) * 0.045 * decay;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
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

class BingBongModel extends StatefulWidget {
  const BingBongModel({super.key});

  @override
  State<BingBongModel> createState() => _BingBongModelState();
}

class _BingBongModelState extends State<BingBongModel> {
  static const String _modelAsset = 'assets/models/peak-bingbong-model.glb';
  static const String _iblAsset = 'assets/models/default_env_ibl.ktx';

  static const double _fill = 1.1;
  static const double _fallbackTanHalfFov = 0.2;

  ThermionViewer? _viewer;
  ThermionAsset? _asset;
  Widget? _surface;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final viewer = await ThermionFlutterPlugin.createViewer();
    _viewer = viewer;

    final asset = await viewer.loadGltf(_modelAsset);
    _asset = asset;
    await viewer.loadIbl(_iblAsset);
    await viewer.setPostProcessing(true);
    await viewer.setAntiAliasing(false, true, false);

    await _frameCamera(_fallbackTanHalfFov);

    await viewer.setRendering(true);
    await viewer.setBackgroundColor(0, 0, 0, 0);

    if (!mounted) return;
    setState(() {
      _surface = ThermionWidget(
        viewer: viewer,
        initial: const SizedBox.shrink(),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _reframeToLens());
  }

  Future<void> _frameCamera(double tanHalfFov) async {
    final viewer = _viewer;
    final asset = _asset;
    if (viewer == null || asset == null) return;

    final bb = await _worldBoundingBox(viewer, asset);
    final size = bb.max - bb.min;
    final center = bb.center;

    final radius = math.max(size.x, size.y) * 0.5;
    final distance = radius / (_fill * tanHalfFov);

    final camera = await viewer.getActiveCamera();
    await camera.lookAt(
      Vector3(center.x, center.y, center.z + distance),
      focus: Vector3(center.x, center.y, center.z),
    );
  }

  Future<Aabb3> _worldBoundingBox(
      ThermionViewer viewer, ThermionAsset asset) async {
    Aabb3? bounds;
    for (final entity in await asset.getChildEntities()) {
      final local = await viewer.getRenderableBoundingBox(entity);
      final extent = local.max - local.min;
      if (extent.x <= 0 && extent.y <= 0 && extent.z <= 0) continue;

      final world = await asset.getWorldTransform(entity: entity);
      local.transform(world);

      if (bounds == null) {
        bounds = Aabb3.copy(local);
      } else {
        bounds.hull(local);
      }
    }
    return bounds ?? Aabb3();
  }

  Future<void> _reframeToLens() async {
    final viewer = _viewer;
    if (viewer == null) return;
    final camera = await viewer.getActiveCamera();

    for (var i = 0; i < 12 && mounted; i++) {
      final proj = await camera.getProjectionMatrix();
      final isPerspective = proj.entry(3, 2).abs() > 0.5;
      final m11 = proj.entry(1, 1).abs();
      if (isPerspective && m11 > 0.01) {
        await _frameCamera(1.0 / m11);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  void dispose() {
    _viewer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _surface ?? const SizedBox.shrink();
  }
}
