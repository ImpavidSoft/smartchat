class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final int? tokenCount;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.tokenCount,
  });
}