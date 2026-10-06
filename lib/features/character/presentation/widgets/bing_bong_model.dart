import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide View;
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

  static const double _canvasScale = 1.5;
  static const double _maxPitch = 1.2;

  ThermionViewer? _viewer;
  ThermionAsset? _asset;
  Widget? _surface;

  Matrix4 _baseTransform = Matrix4.identity();
  Vector3 _center = Vector3.zero();
  double _radius = 0;
  bool _revealed = false;

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
    final bounds = await _worldBoundingBox(viewer, asset);
    _center = bounds.center;
    _radius = (bounds.max - bounds.min).length / 2;
    await viewer.loadIbl(_iblAsset);
    await viewer.setPostProcessing(true);
    await viewer.setAntiAliasing(false, true, false);
    await viewer.setBackgroundColor(0, 0, 0, 0);
    await viewer.setRendering(true);

    if (!mounted) return;
    setState(() {
      _surface = ThermionWidget(
        viewer: viewer,
        initial: const SizedBox.shrink(),
        onResize: _onViewportReady,
      );
    });
  }

  Future<void> _onViewportReady(
    Size size,
    View<Object?> view,
    double pixelRatio,
  ) async {
    await kDefaultResizeCallback(size, view, pixelRatio);
    final camera = await view.getCamera();
    final projection = await camera.getProjectionMatrix();
    await _frameCamera(camera, 1 / projection.entry(1, 1));
    await _viewer?.render();

    if (!mounted || _revealed) return;
    setState(() => _revealed = true);
    unawaited(_arrival.forward());
  }

  Future<void> _frameCamera(Camera<Object?> camera, double tanHalfFov) async {
    final distance = _radius * math.sqrt(1 + 1 / (tanHalfFov * tanHalfFov));
    await camera.lookAt(
      Vector3(_center.x, _center.y, _center.z + distance),
      focus: _center,
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

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            children: [...previousChildren, ?currentChild],
          ),
          child: _revealed
              ? const SizedBox.shrink()
              : const ModelSkeleton(key: ValueKey('skeleton')),
        ),
        if (surface != null)
          FractionallySizedBox(
            widthFactor: _canvasScale,
            heightFactor: _canvasScale,
            child: Opacity(
              opacity: _revealed ? 1 : 0,
              child: AnimatedBuilder(
                animation: _arrivalScale,
                builder: (context, child) =>
                    Transform.scale(scale: _arrivalScale.value, child: child),
                child: surface,
              ),
            ),
          ),
      ],
    );
  }
}
