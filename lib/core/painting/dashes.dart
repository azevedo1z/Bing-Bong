import 'dart:ui';

Path dashPath(Path source, {double dash = 6, double gap = 5}) {
  assert(dash > 0 && gap >= 0, 'o passo precisa avançar, senão o laço trava');

  final result = Path();

  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final end = (distance + dash).clamp(0.0, metric.length);
      result.addPath(metric.extractPath(distance, end), Offset.zero);
      distance = end + gap;
    }
  }

  return result;
}
