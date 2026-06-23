import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/audio_service.dart';
import 'character_state.dart';

final characterProvider =
    StateNotifierProvider<CharacterNotifier, CharacterState>(
      (ref) => CharacterNotifier(),
    );

class CharacterNotifier extends StateNotifier<CharacterState> {
  final AudioService _audioService = AudioService();

  CharacterNotifier() : super(CharacterState.idle) {
    _audioService.onComplete(() {
      if (mounted) state = CharacterState.idle;
    });
  }

  Future<void> onTap() async {
    try {
      final quoteKey = await _audioService.playNext();
      state = CharacterState(isTalking: true, quoteKey: quoteKey);
    } catch (_) {
      state = CharacterState.idle;
    }
  }

  Future<void> playSpecific(String path) async {
    try {
      final quoteKey = await _audioService.playSpecific(path);
      state = CharacterState(isTalking: true, quoteKey: quoteKey);
    } catch (_) {
      state = CharacterState.idle;
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
