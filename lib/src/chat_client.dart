import 'chat_response.dart';

abstract class ChatClient {
  Future<ChatResponse> sendMessage({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int? maxTokens,
  });
  
  static Map<String, String> userMessage(String content) {
    return {'role': 'user', 'content': content};
  }

  static Map<String, String> systemMessage(String content) {
    return {'role': 'system', 'content': content};
  }

  static Map<String, String> assistantMessage(String content) {
    return {'role': 'assistant', 'content': content};
  }
}