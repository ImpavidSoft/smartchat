import 'chat_client.dart';

/// Generic builder for chat clients
class ChatClientBuilder<T extends ChatClient> {
  /// Factory function to create a chat client
  final T Function() _factory;

  /// Creates a new [ChatClientBuilder] with the specified factory function
  ChatClientBuilder(this._factory);

  /// Builds and returns a new chat client instance
  T build() => _factory();
}
