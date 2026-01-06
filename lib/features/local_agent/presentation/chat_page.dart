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
    _messages.add(
      ChatMessage(
        role: ChatRole.assistant,
        content:
            "Welcome to OrionHealth. How can I assist you with your health data today?",
        timestamp: DateTime.now(),
      ),
    );
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
          _MessageComposer(controller: _textController, onSend: _sendMessage),
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
          Text(
            'Orion AI Assistant',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: CyberTheme.primary, size: 8),
              SizedBox(width: 4),
              Text(
                'Online',
                style: TextStyle(fontSize: 12, color: CyberTheme.primary),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})],
      backgroundColor: Colors.black.withOpacity(0.3),
      elevation: 0,
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
    });

    _textController.clear();

    final assistantMessage = ChatMessage(
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
    );
    setState(() => _messages.add(assistantMessage));

    widget.llmService
        .generate(text)
        .listen(
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
    final timeStr =
        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: CyberTheme.secondary.withOpacity(0.3),
              child: Icon(
                Icons.smart_toy,
                color: CyberTheme.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12).copyWith(
                  bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                  bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                ),
                border: Border.all(
                  color: isUser
                      ? CyberTheme.primary.withOpacity(0.3)
                      : CyberTheme.secondary.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? CyberTheme.primary : CyberTheme.secondary)
                        .withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: CyberTheme.secondary.withOpacity(0.3),
            child: const Icon(
              Icons.smart_toy,
              color: CyberTheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: CyberTheme.secondary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(delay: 0),
                const SizedBox(width: 4),
                _PulsingDot(delay: 150),
                const SizedBox(width: 4),
                _PulsingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final int delay;
  const _PulsingDot({required this.delay});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: CyberTheme.secondary,
          shape: BoxShape.circle,
        ),
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message or hold to speak',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: CyberTheme.primary,
                      size: 20,
                    ),
                    onPressed: onSend,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: CyberTheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CyberTheme.primary.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.black),
              onPressed: () {
                // TODO: Implement voice input
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice input coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
