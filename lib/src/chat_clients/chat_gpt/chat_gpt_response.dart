import '../../chat_response.dart';

/// Response from the ChatGPT API
class ChatGptResponse implements ChatResponse {
  /// The ID of the API response
  final String id;

  /// The model used to generate the response
  final String model;

  @override
  final String content;

  /// The number of tokens used for the prompt
  final int promptTokens;

  /// The number of tokens used for the completion
  final int completionTokens;

  @override
  final int totalTokens;

  ChatGptResponse({
    required this.id,
    required this.model,
    required this.content,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  /// Creates a [ChatGptResponse] from a JSON map
  factory ChatGptResponse.fromJson(Map<String, dynamic> json) {
    final choice = json['choices'][0];
    final message = choice['message'];
    final usage = json['usage'];

    return ChatGptResponse(
      id: json['id'],
      model: json['model'],
      content: message['content'],
      promptTokens: usage['prompt_tokens'],
      completionTokens: usage['completion_tokens'],
      totalTokens: usage['total_tokens'],
    );
  }
}
