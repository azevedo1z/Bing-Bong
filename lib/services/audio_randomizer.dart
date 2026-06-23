import 'dart:math';

class AudioRandomizer {
  final List<String> _source;
  final Random _random;
  final List<String> _pool = [];
  String? _lastPlayed;

  AudioRandomizer(this._source, {Random? random})
    : _random = random ?? Random();

  String next() {
    if (_pool.isEmpty) {
      _pool.addAll(_source);
      _shuffle(_pool);

      if (_pool.length > 1 && _pool.first == _lastPlayed) {
        final tmp = _pool[0];
        _pool[0] = _pool[1];
        _pool[1] = tmp;
      }
    }

    final picked = _pool.removeAt(0);
    _lastPlayed = picked;
    return picked;
  }

  void _shuffle(List<String> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }
}
