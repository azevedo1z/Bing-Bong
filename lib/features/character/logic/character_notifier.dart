import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/audio_player_service.dart';
import '../../../services/audio_service.dart';
import 'character_state.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

final characterProvider =
    StateNotifierProvider<CharacterNotifier, CharacterState>(
      (ref) => CharacterNotifier(ref.watch(audioServiceProvider)),
    );

class CharacterNotifier extends StateNotifier<CharacterState> {
  final AudioService _audioService;

  CharacterNotifier(this._audioService) : super(CharacterState.idle) {
    _audioService.onComplete(() {
      if (mounted) state = CharacterState.idle;
    });
  }

  Future<void> onTap() => _play(_audioService.playNext);

  Future<void> playSpecific(String path) =>
      _play(() => _audioService.playSpecific(path));

  Future<void> _play(Future<String> Function() start) async {
    try {
      state = CharacterState(quoteKey: await start());
    } catch (error, stackTrace) {
      debugPrint('Playback failed: $error\n$stackTrace');
      state = CharacterState.idle;
    }
  }
}
