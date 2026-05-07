import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../local_agent/domain/chat_message.dart';
import '../../../local_agent/infrastructure/llm_service.dart';
import '../widgets/message_composer.dart';

enum AssistantState { idle, thinking, responding }

class ChatPage extends StatefulWidget {
  final LlmService llmService;
  const ChatPage({super.key, required this.llmService});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  AssistantState _assistantState = AssistantState.idle;

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
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
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

  void _sendMessage([String? text]) {
    final messageText = text ?? _textController.text.trim();
    if (messageText.isEmpty) return;

    HapticFeedback.lightImpact();

    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: messageText,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _assistantState = AssistantState.thinking;
    });

    if (text == null) _textController.clear();
    _scrollToBottom();

    final assistantMessage = ChatMessage(
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
    );

    setState(() => _messages.add(assistantMessage));

    bool firstChunk = true;
    widget.llmService.generate(messageText).listen(
      (chunk) {
        if (firstChunk) {
          setState(() {
            _assistantState = AssistantState.responding;
            firstChunk = false;
          });
        }
        setState(() {
          _messages.last.content += chunk;
        });
        _scrollToBottom();
      },
      onDone: () {
        setState(() => _assistantState = AssistantState.idle);
        _scrollToBottom();
      },
      onError: (error) {
        setState(() {
          _messages.last.content = 'Error: ${error.toString()}';
          _assistantState = AssistantState.idle;
        });
        _scrollToBottom();
      },
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
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatMessageWidget(message: message);
              },
            ),
          ),
          if (_assistantState != AssistantState.idle)
            _TypingIndicator(state: _assistantState),
          MessageComposer(
            controller: _textController,
            onSend: _sendMessage,
            onQuickPrompt: (prompt) => _sendMessage(prompt),
            isEnabled: _assistantState == AssistantState.idle,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        children: [
          const Text('Orion Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle,
                color: _assistantState == AssistantState.idle ? CyberTheme.primary : Colors.orange,
                size: 8
              ),
              const SizedBox(width: 4),
              Text(
                _assistantState == AssistantState.idle ? 'Online' : 'Processing...',
                style: TextStyle(
                  fontSize: 12,
                  color: _assistantState == AssistantState.idle ? CyberTheme.primary : Colors.orange
                )
              ),
            ],
          )
        ],
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      elevation: 0,
      centerTitle: true,
    );
  }
}

class _ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  const _ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return RepaintBoundary(
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isUser
                  ? CyberTheme.primary.withValues(alpha: 0.15)
                  : Colors.grey[850]?.withValues(alpha: 0.8),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
                ),
                border: Border.all(
                  color: isUser
                    ? CyberTheme.primary.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final AssistantState state;
  const _TypingIndicator({required this.state});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = widget.state == AssistantState.thinking
        ? 'Orion is thinking...'
        : 'Orion is responding...';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.state == AssistantState.thinking ? CyberTheme.secondary : CyberTheme.primary
              ),
            ),
          ),
          const SizedBox(width: 12),
          FadeTransition(
            opacity: _animation,
            child: Text(
              statusText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
