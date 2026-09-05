import 'dart:math';

class AudioRandomizer {
  final List<String> _source;
  final Random _random;
  final List<String> _pool = [];
  String? _lastPlayed;

  AudioRandomizer(this._source, {Random? random})
    : _random = random ?? Random();

  String next() {
    if (_pool.isEmpty) _refill();
    final picked = _pool.removeLast();
    _lastPlayed = picked;
    return picked;
  }

  void _refill() {
    _pool
      ..addAll(_source)
      ..shuffle(_random);
    _avoidImmediateRepeat();
  }

  void _avoidImmediateRepeat() {
    final last = _pool.length - 1;
    if (last < 1 || _pool[last] != _lastPlayed) return;
    final held = _pool[last];
    _pool[last] = _pool[last - 1];
    _pool[last - 1] = held;
  }
}
