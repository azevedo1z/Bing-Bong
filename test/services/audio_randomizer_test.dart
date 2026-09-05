import 'dart:math';

import 'package:bingbong/services/audio_randomizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioRandomizer', () {
    test('plays every line once before repeating any', () {
      const source = ['a', 'b', 'c', 'd'];
      final randomizer = AudioRandomizer(source, random: Random(1));

      final round = List.generate(source.length, (_) => randomizer.next())
        ..sort();

      expect(round, source);
    });

    test('never plays the same line twice in a row, refill included', () {
      const source = ['a', 'b', 'c', 'd'];
      final randomizer = AudioRandomizer(source, random: Random(7));

      var previous = randomizer.next();
      for (var i = 0; i < source.length * 25; i++) {
        final current = randomizer.next();
        expect(current, isNot(previous), reason: 'repeated at draw $i');
        previous = current;
      }
    });

    test('does not mutate the source list', () {
      final source = ['a', 'b', 'c'];
      final randomizer = AudioRandomizer(source, random: Random(2));

      List.generate(6, (_) => randomizer.next());

      expect(source, ['a', 'b', 'c']);
    });

    test('a single-line source keeps returning that line', () {
      final randomizer = AudioRandomizer(const ['only'], random: Random(3));

      expect(randomizer.next(), 'only');
      expect(randomizer.next(), 'only');
    });
  });
}
