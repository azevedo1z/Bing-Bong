class CharacterState {
  final String? quoteKey;

  const CharacterState({this.quoteKey});

  static const idle = CharacterState();

  bool get isTalking => quoteKey != null;
}
