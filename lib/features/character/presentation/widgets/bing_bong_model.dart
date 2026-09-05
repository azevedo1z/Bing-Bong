import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thermion_flutter/thermion_flutter.dart';

import 'model_skeleton.dart';

class CharacterOrbitController {
  _BingBongModelState? _state;

  void rotate(double deltaYaw, double deltaPitch) =>
      _state?._applyDrag(deltaYaw, deltaPitch);

  void release() => _state?._release();
}

class BingBongModel extends StatefulWidget {
  final CharacterOrbitController? orbit;

  const BingBongModel({super.key, this.orbit});

  @override
  State<BingBongModel> createState() => _BingBongModelState();
}

class _BingBongModelState extends State<BingBongModel>
    with TickerProviderStateMixin {
  static const String _modelAsset = 'assets/models/peak-bingbong-model.glb';
  static const String _iblAsset = 'assets/models/default_env_ibl.ktx';

  static const double _fill = 1.1;
  static const double _fallbackTanHalfFov = 0.2;
  static const double _maxPitch = 1.2;

  ThermionViewer? _viewer;
  ThermionAsset? _asset;
  Widget? _surface;

  Matrix4 _baseTransform = Matrix4.identity();
  Vector3 _center = Vector3.zero();

  double _yaw = 0;
  double _pitch = 0;
  bool _applying = false;

  late final AnimationController _returnController;
  double _returnFromYaw = 0;
  double _returnFromPitch = 0;

  late final AnimationController _arrival;
  late final CurvedAnimation _arrivalCurve;
  late final Animation<double> _arrivalScale;

  @override
  void initState() {
    super.initState();
    widget.orbit?._state = this;
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(_onReturnTick);

    _arrival = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _arrivalCurve = CurvedAnimation(parent: _arrival, curve: Curves.elasticOut);
    _arrivalScale = Tween<double>(begin: 0.72, end: 1.0).animate(_arrivalCurve);

    _setup();
  }

  Future<void> _setup() async {
    try {
      await _createViewport();
    } catch (error, stackTrace) {
      debugPrint('3D viewport failed to load: $error\n$stackTrace');
    }
  }

  Future<void> _createViewport() async {
    final viewer = await ThermionFlutterPlugin.createViewer();
    if (!mounted) {
      await viewer.dispose();
      return;
    }
    _viewer = viewer;

    final asset = await viewer.loadGltf(_modelAsset);
    _asset = asset;
    _baseTransform = await asset.getLocalTransform();
    _center = (await _worldBoundingBox(viewer, asset)).center;
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

    unawaited(_arrival.forward());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_reframeToLens()),
    );
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
    ThermionViewer viewer,
    ThermionAsset asset,
  ) async {
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

  void _applyDrag(double deltaYaw, double deltaPitch) {
    _returnController.stop();
    _yaw += deltaYaw;
    _pitch = (_pitch + deltaPitch).clamp(-_maxPitch, _maxPitch);
    _requestApply();
  }

  void _release() {
    _yaw = _shortestAngleToFront(_yaw);
    if (_yaw == 0 && _pitch == 0) return;
    _returnFromYaw = _yaw;
    _returnFromPitch = _pitch;
    _returnController.forward(from: 0);
  }

  double _shortestAngleToFront(double angle) {
    const fullTurn = 2 * math.pi;
    final wrapped = angle.remainder(fullTurn);
    if (wrapped > math.pi) return wrapped - fullTurn;
    if (wrapped < -math.pi) return wrapped + fullTurn;
    return wrapped;
  }

  void _onReturnTick() {
    final remaining =
        1.0 - Curves.easeOutCubic.transform(_returnController.value);
    _yaw = _returnFromYaw * remaining;
    _pitch = _returnFromPitch * remaining;
    _requestApply();
  }

  void _requestApply() {
    if (_applying) return;
    _applying = true;
    _drain();
  }

  Future<void> _drain() async {
    try {
      final asset = _asset;
      while (mounted && asset != null) {
        final yaw = _yaw;
        final pitch = _pitch;
        await asset.setTransform(_orbitTransform(yaw, pitch));
        if (yaw == _yaw && pitch == _pitch) break;
      }
    } finally {
      _applying = false;
    }
  }

  Matrix4 _orbitTransform(double yaw, double pitch) {
    final rotation = Matrix4.identity()
      ..rotateY(yaw)
      ..rotateX(pitch);
    return Matrix4.translationValues(_center.x, _center.y, _center.z)
        .multiplied(rotation)
        .multiplied(
          Matrix4.translationValues(-_center.x, -_center.y, -_center.z),
        )
        .multiplied(_baseTransform);
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
    widget.orbit?._state = null;
    _returnController.dispose();
    _arrivalCurve.dispose();
    _arrival.dispose();
    final viewer = _viewer;
    if (viewer != null) unawaited(viewer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = _surface;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        children: [...previousChildren, ?currentChild],
      ),
      child: surface == null
          ? const ModelSkeleton(key: ValueKey('skeleton'))
          : AnimatedBuilder(
              key: const ValueKey('model'),
              animation: _arrivalScale,
              builder: (context, child) =>
                  Transform.scale(scale: _arrivalScale.value, child: child),
              child: surface,
            ),
    );
  }
}
