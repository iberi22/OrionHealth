import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../local_agent/domain/chat_message.dart';
import '../domain/entities/ai_query.dart';
import '../domain/repositories/i_ai_repository.dart';

enum AiAssistantStatus { idle, thinking, responding, error }

class AiAssistantState extends Equatable {
  final List<ChatMessage> messages;
  final AiAssistantStatus status;
  final String? errorMessage;

  const AiAssistantState({
    required this.messages,
    this.status = AiAssistantStatus.idle,
    this.errorMessage,
  });

  factory AiAssistantState.initial() {
    return AiAssistantState(
      messages: [
        ChatMessage(
          role: ChatRole.assistant,
          content: "Welcome to OrionHealth. How can I assist you with your health data today?",
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  AiAssistantState copyWith({
    List<ChatMessage>? messages,
    AiAssistantStatus? status,
    String? errorMessage,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, status, errorMessage];
}

@injectable
class AiAssistantCubit extends Cubit<AiAssistantState> {
  final IAiRepository _repository;
  StreamSubscription? _subscription;

  AiAssistantCubit(this._repository) : super(AiAssistantState.initial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    final assistantMessage = ChatMessage(
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage)
      ..add(assistantMessage);

    emit(state.copyWith(
      messages: updatedMessages,
      status: AiAssistantStatus.thinking,
    ));

    await _subscription?.cancel();

    final query = AiQuery(text: text, timestamp: userMessage.timestamp);
    bool firstChunk = true;

    _subscription = _repository.askStreaming(query).listen(
      (chunk) {
        if (firstChunk) {
          emit(state.copyWith(status: AiAssistantStatus.responding));
          firstChunk = false;
        }

        final lastMessage = state.messages.last;
        final updatedLastMessage = ChatMessage(
          id: lastMessage.id,
          role: lastMessage.role,
          content: lastMessage.content + chunk,
          timestamp: lastMessage.timestamp,
          citations: lastMessage.citations,
        );

        final newMessages = List<ChatMessage>.from(state.messages)
          ..[state.messages.length - 1] = updatedLastMessage;

        emit(state.copyWith(messages: newMessages));
      },
      onDone: () {
        emit(state.copyWith(status: AiAssistantStatus.idle));
      },
      onError: (error) {
        final lastMessage = state.messages.last;
        final updatedLastMessage = ChatMessage(
          id: lastMessage.id,
          role: lastMessage.role,
          content: '${lastMessage.content}\nError: $error',
          timestamp: lastMessage.timestamp,
          citations: lastMessage.citations,
        );

        final newMessages = List<ChatMessage>.from(state.messages)
          ..[state.messages.length - 1] = updatedLastMessage;

        emit(state.copyWith(
          messages: newMessages,
          status: AiAssistantStatus.error,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
