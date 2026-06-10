import 'package:equatable/equatable.dart';
import '../../local_agent/domain/chat_message.dart';

enum AiAssistantStatus { initial, thinking, responding, error }

class AiAssistantState extends Equatable {
  final AiAssistantStatus status;
  final List<ChatMessage> messages;
  final String? error;

  const AiAssistantState({
    this.status = AiAssistantStatus.initial,
    this.messages = const [],
    this.error,
  });

  @override
  List<Object?> get props => [status, messages, error];

  AiAssistantState copyWith({
    AiAssistantStatus? status,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return AiAssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}
