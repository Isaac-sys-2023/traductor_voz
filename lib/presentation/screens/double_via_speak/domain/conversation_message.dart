class ConversationMessage {
  final String speaker;
  final String originalText;
  final String translatedText;
  final String originalLanguage;
  final String translatedLanguage;
  final DateTime timestamp;

  ConversationMessage({
    required this.speaker,
    required this.originalText,
    required this.translatedText,
    required this.originalLanguage,
    required this.translatedLanguage,
    required this.timestamp,
  });
}
