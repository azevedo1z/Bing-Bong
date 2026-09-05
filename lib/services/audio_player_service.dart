import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../core/constants/audio_constants.dart';
import 'audio_randomizer.dart';
import 'audio_service.dart';

class AudioPlayerService implements AudioService {
  final AudioPlayer _player = AudioPlayer();
  final AudioRandomizer _randomizer = AudioRandomizer(kAudioFiles);
  StreamSubscription<void>? _completeSub;
  bool _isPlaying = false;

  @override
  void onComplete(void Function() callback) {
    unawaited(_completeSub?.cancel());
    _completeSub = _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      callback();
    });
  }

  @override
  Future<String> playNext() => _play(_randomizer.next());

  @override
  Future<String> playSpecific(String path) => _play(path);

  Future<String> _play(String path) async {
    if (_isPlaying) await _player.stop();
    await _player.play(AssetSource(path));
    _isPlaying = true;
    return path;
  }

  @override
  Future<void> dispose() async {
    await _completeSub?.cancel();
    _completeSub = null;
    await _player.dispose();
  }
}
