// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/voice_chat_cubit.dart';
import '../../application/voice_chat_state.dart';

class VoiceInputButton extends StatelessWidget {
  const VoiceInputButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceChatCubit, VoiceChatState>(
      builder: (context, state) {
        final isRecording = state.status == VoiceChatStatus.recording;
        final isProcessing = state.status == VoiceChatStatus.processing;
        final isSpeaking = state.status == VoiceChatStatus.speaking;

        return GestureDetector(
          onLongPressStart: (_) => context.read<VoiceChatCubit>().startRecording(),
          onLongPressEnd: (_) => context.read<VoiceChatCubit>().stopRecording(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecording)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Suelta para enviar',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: isRecording ? Colors.red : Colors.blue[600],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? Colors.red : Colors.blue).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: isRecording ? 10 * state.currentAudioLevel : 5,
                    ),
                  ],
                ),
                child: Center(
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Icon(
                          isRecording ? Icons.mic : (isSpeaking ? Icons.stop : Icons.mic_none),
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
              if (!isRecording && !isProcessing && !isSpeaking)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Mantén para hablar',
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                ),
              if (isSpeaking)
                TextButton(
                  onPressed: () => context.read<VoiceChatCubit>().interrupt(),
                  child: const Text('Interrumpir', style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        );
      },
    );
  }
}
