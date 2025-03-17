abstract class ChatResponse {
  String get content;

  /// The total number of tokens used.  For calculating bill
  int get totalTokens;
}

