import 'package:flutter/material.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

class ChatPage extends StatefulWidget {
  final LlmService llmService;
  const ChatPage({super.key, required this.llmService});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Add initial AI message
    _messages.add(ChatMessage(
      role: ChatRole.assistant,
      content: "Welcome to OrionHealth. How can I assist you with your health data today?",
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatMessageWidget(message: message);
              },
            ),
          ),
          if (_isGenerating) const _TypingIndicator(),
          _MessageComposer(
            controller: _textController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Column(
        children: [
          Text('Orion AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: CyberTheme.primary, size: 8),
              SizedBox(width: 4),
              Text('Online', style: TextStyle(fontSize: 12, color: CyberTheme.primary)),
            ],
          )
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ],
      backgroundColor: Colors.black.withOpacity(0.3),
      elevation: 0,
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(role: ChatRole.user, content: text, timestamp: DateTime.now());
    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
    });

    _textController.clear();

    final assistantMessage = ChatMessage(role: ChatRole.assistant, content: '', timestamp: DateTime.now());
    setState(() => _messages.add(assistantMessage));

    widget.llmService.generate(text).listen(
      (chunk) {
        setState(() => _messages.last.content += chunk);
      },
      onDone: () => setState(() => _isGenerating = false),
      onError: (error) {
        setState(() {
          _messages.last.content = 'Error: ${error.toString()}';
          _isGenerating = false;
        });
      },
    );
  }
}

class _ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  const _ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey[900]?.withOpacity(0.5) : Colors.grey[800]?.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
          ),
          border: Border.all(color: isUser ? CyberTheme.primary.withOpacity(0.3) : CyberTheme.secondary.withOpacity(0.3)),
        ),
        child: Text(message.content),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(Icons.computer, color: CyberTheme.secondary, size: 24),
          SizedBox(width: 8),
          Text('Orion AI is thinking...', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageComposer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.grey[900]?.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: CyberTheme.primary),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
