import 'package:http/http.dart' as http;

import 'chat_client_builder.dart';
import 'chat_clients/chat_gpt/chat_gpt_client.dart';

/// Provider for chat client dependencies
class ChatClientProvider {
  /// Creates a new [ChatClientBuilder] for ChatGptClient
  static ChatClientBuilder<ChatGptRequest> createGptClientBuilder({
    required String apiKey,
    String model = 'gpt-4-turbo',
    String apiUrl = 'https://api.openai.com/v1/chat/completions',
    http.Client? httpClient,
  }) {
    return ChatClientBuilder<ChatGptRequest>(() => ChatGptRequest(
      apiKey: apiKey,
      model: model,
      apiUrl: apiUrl,
      httpClient: httpClient,
    ));
  }
}