import 'package:smart_chat/src/chat_response.dart';

import '../../chart_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../chat_client.dart';
import 'chat_gpt_response.dart';

class ChatGptRequest implements ChatClient {

  final String apiUrl;

  final String apiKey;

  final String model;

  final http.Client _httpClient;

  @override
  ChatGptRequest({
    required this.apiKey,
    this.model = 'gpt-4-turbo',
    this.apiUrl = 'https://api.openai.com/v1/chat/completions',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  Future<ChatResponse> sendMessage({required List<Map<String, String>> messages,  temperature = 0.7, int? maxTokens,  }) async {
    final headers = { 'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey', };

    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
    });

    try {
      final response = await _httpClient.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ChatGptResponse.fromJson(jsonResponse);
      } else {
        throw ChatException( 'API request failed with status: ${response.statusCode}', response.statusCode, response.body, );
      }
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to send message: $e', 0, null);
    }
  }



}