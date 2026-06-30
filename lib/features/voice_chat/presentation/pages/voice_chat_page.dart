// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/connection_status_indicator.dart';
import '../../../../core/services/aicore_service.dart';
import '../../application/voice_chat_cubit.dart';
import '../../application/voice_chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_input_button.dart';

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  State<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> with TickerProviderStateMixin {
  late final VoiceChatCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<VoiceChatCubit>()..init();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    _textController.dispose();
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
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Orion — Chat de Voz',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () => _cubit.clearHistory(),
              tooltip: 'Limpiar conversación',
            ),
          ],
        ),
        body: BlocConsumer<VoiceChatCubit, VoiceChatState>(
          listener: (context, state) {
            if (state.messages.isNotEmpty) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            if (state.status == VoiceChatStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white70));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LocalConnectionStatus(
                    isLocalAIReady: getIt<AIService>().currentState == AIServiceState.ready,
                    isMemoryReady: true, // Assuming for now
                    memoryCount: 0, // Placeholder
                    onRetry: () => getIt<AIService>().initialize(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAgentView(state),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) => MessageBubble(message: state.messages[index]),
                  ),
                ),
                _buildStatusBar(state),
                _buildControls(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAgentView(VoiceChatState state) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.blue.withValues(alpha: 0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.psychology, color: Colors.white, size: 64),
        ),
      ),
    );
  }

  Widget _buildStatusBar(VoiceChatState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        state.statusMessage ?? '',
        style: const TextStyle(color: Colors.white60, fontSize: 14),
      ),
    );
  }

  Widget _buildControls(VoiceChatState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) {
                _cubit.sendMessage(val);
                _textController.clear();
              },
            ),
          ),
          const SizedBox(width: 16),
          const VoiceInputButton(),
        ],
      ),
    );
  }
}
