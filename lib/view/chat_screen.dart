import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../src/chart_client_provider.dart';
import '../src/chart_exception.dart';
import '../src/chat_client.dart';
import '../src/chat_clients/chat_gpt/chat_gpt_constants.dart';
import '../src/chat_message.dart';

class ChatGptApp extends StatelessWidget {
  const ChatGptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Flutter Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Split view controller
  double _splitPosition = 0.5; // Initial split at 50%

  // Initialize the ChatGptClient
  late final ChatClient _chatClient;
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();

    // Create the client using our ChatClientBuilder
    final chatClientBuilder = ChatClientProvider.createGptClientBuilder(
      apiKey: ChatGptConstants.apiKey,
      model: ChatGptConstants.model,
      apiUrl: ChatGptConstants.apiUrl,
    );

    _chatClient = chatClientBuilder.build();

    // Add system message to initialize the conversation
    _conversationHistory.add(ChatClient.systemMessage(
        'You are a helpful assistant that provides concise and accurate information.'
    ));

    // Listen for focus changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessageToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text('Message copied to clipboard'), duration: Duration(seconds: 2), ),
        );
      }
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
      ));
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      // Add user message to history
      _conversationHistory.add(ChatClient.userMessage(message));

      // Get response from API
      final response = await _chatClient.sendMessage(
        messages: _conversationHistory,
        temperature: 0.7,
      );

      // Add assistant's response to history
      _conversationHistory.add(ChatClient.assistantMessage(response.content));

      setState(() {
        _messages.add(ChatMessage(
          text: response.content,
          isUser: false,
          tokenCount: response.totalTokens,
        ));
        _isLoading = false;
      });
    } on ChatException catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Error: ${e.message}",
          isUser: false,
          isError: true,
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  // Show settings dialog
  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI Model Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Model'),
                subtitle: Text(ChatGptConstants.model),
                leading: const Icon(Icons.psychology),
                dense: true,
              ),
              const Divider(),
              const Text('Conversation Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Auto-scroll'),
                subtitle: const Text('Automatically scroll to bottom on new messages'),
                value: true, // You can make this a state variable
                onChanged: (value) {
                  // Add functionality to toggle auto-scroll
                  Navigator.pop(context);
                  setState(() {
                    // Update your auto-scroll setting
                  });
                },
                dense: true,
              ),
              ListTile(
                title: const Text('Clear Conversation'),
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                onTap: () {
                  Navigator.pop(context);
                  // Show confirmation dialog before clearing
                  _showClearConfirmation();
                },
                dense: true,
              ),
              const Divider(),
              const Text('Display Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Default Split Position'),
                subtitle: Text('${(_splitPosition * 100).toStringAsFixed(0)}%'),
                leading: const Icon(Icons.height),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  // Show a slider dialog to adjust default split
                  _showSplitPositionDialog();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog before clearing conversation
  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text('Are you sure you want to clear the entire conversation? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _conversationHistory.clear();
                _conversationHistory.add(ChatClient.systemMessage(
                    'You are a helpful assistant that provides concise and accurate information.'
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Show dialog to adjust split position
  void _showSplitPositionDialog() {
    double tempSplitPosition = _splitPosition;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Split Position'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(tempSplitPosition * 100).toStringAsFixed(0)}%'),
              Slider(
                value: tempSplitPosition,
                min: 0.2,
                max: 0.8,
                divisions: 12,
                label: '${(tempSplitPosition * 100).toStringAsFixed(0)}%',
                onChanged: (value) {
                  setDialogState(() {
                    tempSplitPosition = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _splitPosition = tempSplitPosition;
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Chat'),
        centerTitle: true,
        actions: [
          // Settings menu button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Resizable split view
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final splitHeight = height * _splitPosition;

                return Stack(
                  children: [
                    // Message list
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: splitHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _messages.isEmpty
                            ? const Center(
                          child: Text(
                            'Send a message to start a conversation',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                            : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageItem(_messages[index]);
                          },
                        ),
                      ),
                    ),
                    // Resizable divider
                    Positioned(
                      top: splitHeight - 10,
                      left: 0,
                      right: 0,
                      height: 20,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            _splitPosition += details.delta.dy / height;
                            // Constrain the split position
                            if (_splitPosition < 0.2) _splitPosition = 0.2;
                            if (_splitPosition > 0.8) _splitPosition = 0.8;
                          });
                        },
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Message composer
                    Positioned(
                      top: splitHeight + 10,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            if (_isLoading)
                              const LinearProgressIndicator(),
                            Expanded(
                              child: _buildMessageComposer(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          // Show copy menu on long press
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Message Options',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Message'),
                          onPressed: () {
                            _copyMessageToClipboard(message.text);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
          decoration: BoxDecoration(
            color: message.isUser
                ? Colors.blue[100]
                : message.isError
                ? Colors.red[100]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            // Add a slight border when message is tapped
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Using SelectableText for built-in text selection
              SelectableText(
                message.text,
                style: TextStyle(
                  color: message.isError ? Colors.red[900] : Colors.black87,
                ),
                // Enable text selection by default
                enableInteractiveSelection: true,
                // Add a context menu builder for enhanced copy functionality
                contextMenuBuilder: (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar(
                    anchors: editableTextState.contextMenuAnchors,
                    children: [
                      InkWell(
                        onTap: () {
                          // Get selected text
                          final TextSelection selection = editableTextState.textEditingValue.selection;
                          final String selectedText = selection.textInside(message.text);

                          // Copy to clipboard
                          Clipboard.setData(ClipboardData(text: selectedText));
                          editableTextState.hideToolbar();

                          // Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected text copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: const Text('Copy'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // Copy entire message regardless of selection
                          Clipboard.setData(ClipboardData(text: message.text));
                          editableTextState.hideToolbar();

                          // Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Full message copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: const Text('Copy Full Message'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          editableTextState.selectAll(SelectionChangedCause.toolbar);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: const Text('Select All'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (!message.isUser && message.tokenCount != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Tokens used: ${message.tokenCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              // Add copy indicator to show the balloon is tappable
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Icon(
                    Icons.touch_app,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _messageController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Type a message',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ),
        minLines: 1,
        maxLines: null, // Allow unlimited lines
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (text) {
          if (text.isNotEmpty) _sendMessage();
        },
        // Change from TextInputAction.newline to TextInputAction.send
        textInputAction: TextInputAction.send,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}