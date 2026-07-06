import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/usecases/get_chat_history_usecase.dart';

class MockVectorStoreService extends Mock implements VectorStoreService {}

void main() {
  late GetChatHistoryUseCase useCase;
  late MockVectorStoreService mockStoreService;

  setUp(() {
    mockStoreService = MockVectorStoreService();
    useCase = GetChatHistoryUseCase(mockStoreService);
  });

  group('GetChatHistoryUseCase', () {
    test('should return history from VectorStoreService', () async {
      final tHistory = [
        ChatMessage(role: ChatRole.user, content: 'Hello', timestamp: DateTime.now()),
        ChatMessage(role: ChatRole.assistant, content: 'Hi', timestamp: DateTime.now()),
      ];

      when(() => mockStoreService.getRecentMessages()).thenAnswer((_) async => tHistory);

      final result = await useCase();

      expect(result, tHistory);
      verify(() => mockStoreService.getRecentMessages()).called(1);
    });
  });
}
