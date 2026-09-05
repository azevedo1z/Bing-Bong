abstract interface class AudioService {
  void onComplete(void Function() callback);

  Future<String> playNext();

  Future<String> playSpecific(String path);

  Future<void> dispose();
}
