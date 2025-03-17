/// Exception thrown when an error occurs while using the chat API
class ChatException implements Exception {
  /// A human-readable error message
  final String message;

  /// The HTTP status code, if applicable
  final int statusCode;

  /// The raw response body, if available
  final String? responseBody;

  ChatException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() => 'ChatException: $message';
}