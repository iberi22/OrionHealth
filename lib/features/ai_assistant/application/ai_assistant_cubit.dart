import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../local_agent/domain/chat_message.dart';
import '../domain/entities/ai_query.dart';
import '../domain/repositories/ai_repository.dart';
export 'ai_assistant_state.dart';

@injectable
class AiAssistantCubit extends Cubit<AiAssistantState> {
  final AiRepository _repository;
  StreamSubscription? _subscription;

  AiAssistantCubit(this._repository) : super(const AiAssistantState()) {
    // Add initial AI message
    final welcomeMessage = ChatMessage(
      role: ChatRole.assistant,
      content: "Welcome to OrionHealth. How can I assist you with your health data today?",
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(messages: [welcomeMessage]));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);

    final assistantPlaceholder = ChatMessage(
      role: ChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
    );

    updatedMessages.add(assistantPlaceholder);

    emit(state.copyWith(
      status: AiAssistantStatus.thinking,
      messages: updatedMessages,
    ));

    await _subscription?.cancel();

    bool firstChunk = true;
    _subscription = _repository.askQuestion(AiQuery(text: text)).listen(
      (chunk) {
        if (firstChunk) {
          emit(state.copyWith(status: AiAssistantStatus.responding));
          firstChunk = false;
        }

        final messages = List<ChatMessage>.from(state.messages);
        final lastMessage = messages.last;
        messages[messages.length - 1] = lastMessage.copyWith(
          content: lastMessage.content + chunk,
        );

        emit(state.copyWith(messages: messages));
      },
      onDone: () {
        if (state.status != AiAssistantStatus.error) {
          emit(state.copyWith(status: AiAssistantStatus.initial));
        }
      },
      onError: (error) {
        final messages = List<ChatMessage>.from(state.messages);
        final lastMessage = messages.last;
        messages[messages.length - 1] = lastMessage.copyWith(
          content: 'Error: ${error.toString()}',
        );
        emit(state.copyWith(
          status: AiAssistantStatus.error,
          messages: messages,
          error: error.toString(),
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
