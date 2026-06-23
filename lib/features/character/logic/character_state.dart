class CharacterState {
  final bool isTalking;
  final String quoteKey;

  const CharacterState({this.isTalking = false, this.quoteKey = ''});

  static const idle = CharacterState();
}
