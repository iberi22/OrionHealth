import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../local_agent/domain/chat_message.dart';
import '../../../local_agent/infrastructure/llm_service.dart';
import '../../application/ai_assistant_cubit.dart';
import '../../infrastructure/ai_repository_impl.dart';
import '../widgets/message_composer.dart';
import '../../../../../core/theme/app_colors.dart';

class ChatPage extends StatefulWidget {
  final LlmService? llmService;
  const ChatPage({super.key, this.llmService});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        if (widget.llmService != null) {
          return AiAssistantCubit(AiRepositoryImpl(widget.llmService!));
        }
        return getIt<AiAssistantCubit>();
      },
      child: BlocConsumer<AiAssistantCubit, AiAssistantState>(
        listener: (context, state) {
          _scrollToBottom();
        },
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(state.status),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _ChatMessageWidget(message: message);
                    },
                  ),
                ),
                if (state.status == AiAssistantStatus.thinking ||
                    state.status == AiAssistantStatus.responding)
                  _TypingIndicator(status: state.status),
                MessageComposer(
                  controller: _textController,
                  onSend: () {
                    final messageText = _textController.text.trim();
                    if (messageText.isEmpty) return;
                    HapticFeedback.lightImpact();
                    context.read<AiAssistantCubit>().sendMessage(messageText);
                    _textController.clear();
                  },
                  onQuickPrompt: (prompt) {
                    HapticFeedback.lightImpact();
                    context.read<AiAssistantCubit>().sendMessage(prompt);
                  },
                  isEnabled: state.status == AiAssistantStatus.idle ||
                      state.status == AiAssistantStatus.error,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(AiAssistantStatus status) {
    final isProcessing = status == AiAssistantStatus.thinking || status == AiAssistantStatus.responding;
    return AppBar(
      title: Column(
        children: [
          const Text('Orion Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle,
                color: !isProcessing ? AppColors.primary : Colors.orange,
                size: 8
              ),
              const SizedBox(width: 4),
              Text(
                !isProcessing ? 'Online' : 'Processing...',
                style: TextStyle(
                  fontSize: 12,
                  color: !isProcessing ? AppColors.primary : Colors.orange
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
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.grey[850]?.withValues(alpha: 0.8),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
                ),
                border: Border.all(
                  color: isUser
                    ? AppColors.primary.withValues(alpha: 0.3)
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
  final AiAssistantStatus status;
  const _TypingIndicator({required this.status});

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
    final statusText = widget.status == AiAssistantStatus.thinking
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
                widget.status == AiAssistantStatus.thinking ? AppColors.secondary : AppColors.primary
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
