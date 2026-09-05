import 'package:bingbong/features/character/logic/character_notifier.dart';
import 'package:bingbong/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAudioService implements AudioService {
  _FakeAudioService({this.failing = false});

  final bool failing;
  final List<String> played = [];
  void Function()? _onComplete;

  void finishPlayback() => _onComplete?.call();

  @override
  void onComplete(void Function() callback) => _onComplete = callback;

  @override
  Future<String> playNext() => _play('audio/next.mp3');

  @override
  Future<String> playSpecific(String path) => _play(path);

  Future<String> _play(String path) async {
    if (failing) throw StateError('no audio device');
    played.add(path);
    return path;
  }

  @override
  Future<void> dispose() async {}
}

CharacterNotifier _notifierWith(AudioService audio) {
  final notifier = CharacterNotifier(audio);
  addTearDown(notifier.dispose);
  return notifier;
}

void main() {
  group('CharacterNotifier', () {
    test('starts idle', () {
      expect(_notifierWith(_FakeAudioService()).state.isTalking, isFalse);
    });

    test('a tap plays the next line and exposes its key', () async {
      final audio = _FakeAudioService();
      final notifier = _notifierWith(audio);

      await notifier.onTap();

      expect(audio.played, ['audio/next.mp3']);
      expect(notifier.state.quoteKey, 'audio/next.mp3');
      expect(notifier.state.isTalking, isTrue);
    });

    test('the catchphrase plays the line it was given', () async {
      final audio = _FakeAudioService();
      final notifier = _notifierWith(audio);

      await notifier.playSpecific('audio/im bing bong.mp3');

      expect(audio.played, ['audio/im bing bong.mp3']);
      expect(notifier.state.quoteKey, 'audio/im bing bong.mp3');
    });

    test('goes back to idle when playback finishes', () async {
      final audio = _FakeAudioService();
      final notifier = _notifierWith(audio);
      await notifier.onTap();

      audio.finishPlayback();

      expect(notifier.state.isTalking, isFalse);
    });

    test('stays idle when playback throws', () async {
      final notifier = _notifierWith(_FakeAudioService(failing: true));

      await notifier.onTap();

      expect(notifier.state.isTalking, isFalse);
    });
  });
}
