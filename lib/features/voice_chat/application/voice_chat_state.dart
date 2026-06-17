import 'package:equatable/equatable.dart';
import '../state/app_state_manager.dart';

class VoiceChatState extends Equatable {
  final VoiceChatStatus status;
  final bool isRecording;
  final bool isProcessing;
  final String? errorMessage;

  const VoiceChatState({
    this.status = VoiceChatStatus.idle,
    this.isRecording = false,
    this.isProcessing = false,
    this.errorMessage,
  });

  VoiceChatState copyWith({
    VoiceChatStatus? status,
    bool? isRecording,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return VoiceChatState(
      status: status ?? this.status,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isRecording, isProcessing, errorMessage];
}

enum VoiceChatStatus { idle, listening, processing, speaking, error }
