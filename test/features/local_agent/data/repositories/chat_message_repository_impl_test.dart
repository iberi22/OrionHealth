import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/data/datasources/chat_message_local_datasource.dart';
import 'package:orionhealth_health/features/local_agent/data/repositories/chat_message_repository_impl.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';

class MockChatMessageLocalDataSource extends Mock
    implements ChatMessageLocalDataSource {}

void main() {
  late MockChatMessageLocalDataSource mockDataSource;
  late ChatMessageRepository repository;

  setUpAll(() {
    registerFallbackValue(ChatMessage(
      role: ChatRole.user,
      content: '',
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    mockDataSource = MockChatMessageLocalDataSource();
    repository = ChatMessageRepository(mockDataSource);
  });

  group('ChatMessageRepository', () {
    test('getMessages delegates to local data source', () async {
      final messages = [
        ChatMessage(
          role: ChatRole.user,
          content: 'Hello',
          timestamp: DateTime.now(),
        ),
      ];
      when(() => mockDataSource.getMessages(any()))
          .thenAnswer((_) async => messages);

      final result = await repository.getMessages(10);

      expect(result, messages);
      verify(() => mockDataSource.getMessages(10)).called(1);
    });

    test('saveMessage delegates to local data source', () async {
      final message = ChatMessage(
        role: ChatRole.assistant,
        content: 'Hi there',
        timestamp: DateTime.now(),
      );
      when(() => mockDataSource.saveMessage(any()))
          .thenAnswer((_) async => Future.value());

      await repository.saveMessage(message);

      verify(() => mockDataSource.saveMessage(message)).called(1);
    });

    test('clearHistory delegates to local data source', () async {
      when(() => mockDataSource.clearHistory())
          .thenAnswer((_) async => Future.value());

      await repository.clearHistory();

      verify(() => mockDataSource.clearHistory()).called(1);
    });
  });
}
