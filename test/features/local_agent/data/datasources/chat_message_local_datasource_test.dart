import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/local_agent/data/datasources/chat_message_local_datasource.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';

class MockIsar extends Mock implements Isar {}
class MockChatMessagesCollection extends Mock implements IsarCollection<ChatMessage> {}
class MockQueryBuilder extends Mock implements QueryBuilder<ChatMessage, ChatMessage, QSortBy> {}
class MockQuery extends Mock implements Query<ChatMessage> {}

void main() {
  late MockIsar mockIsar;
  late MockChatMessagesCollection mockCollection;
  late ChatMessageLocalDataSource dataSource;
  late MockQueryBuilder mockQueryBuilder;
  late MockQuery mockQuery;

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockChatMessagesCollection();
    mockQueryBuilder = MockQueryBuilder();
    mockQuery = MockQuery();
    dataSource = ChatMessageLocalDataSource(mockIsar);

    when(() => mockIsar.chatMessages).thenReturn(mockCollection);
  });

  group('ChatMessageLocalDataSource', () {
    final sampleMessage = ChatMessage(
      role: ChatRole.user,
      content: 'Test message',
      timestamp: DateTime(2026, 6, 18),
    );

    group('getMessages', () {
      test('returns messages sorted by timestamp descending with limit', () async {
        when(() => mockCollection.where()).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.sortByTimestampDesc()).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.limit(10)).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.findAll()).thenAnswer((_) async => [sampleMessage]);

        final messages = await dataSource.getMessages(10);

        expect(messages, hasLength(1));
        expect(messages.first.content, 'Test message');
        verify(() => mockQueryBuilder.sortByTimestampDesc()).called(1);
        verify(() => mockQueryBuilder.limit(10)).called(1);
      });

      test('returns empty list when no messages', () async {
        when(() => mockCollection.where()).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.sortByTimestampDesc()).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.limit(50)).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.findAll()).thenAnswer((_) async => []);

        final messages = await dataSource.getMessages(50);

        expect(messages, isEmpty);
      });
    });

    group('saveMessage', () {
      test('saves message in a write transaction', () async {
        when(() => mockIsar.writeTxn(any())).thenAnswer((invocation) async {
          final fn = invocation.positionalArguments[0] as Future<void> Function();
          await fn();
        });
        when(() => mockCollection.put(sampleMessage)).thenAnswer((_) async => 1);

        await dataSource.saveMessage(sampleMessage);

        verify(() => mockIsar.writeTxn(any())).called(1);
        verify(() => mockCollection.put(sampleMessage)).called(1);
      });
    });

    group('clearHistory', () {
      test('deletes all messages in a write transaction', () async {
        when(() => mockIsar.writeTxn(any())).thenAnswer((invocation) async {
          final fn = invocation.positionalArguments[0] as Future<void> Function();
          await fn();
        });
        when(() => mockCollection.where()).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.deleteAll()).thenAnswer((_) async => 5);

        await dataSource.clearHistory();

        verify(() => mockIsar.writeTxn(any())).called(1);
        verify(() => mockQueryBuilder.deleteAll()).called(1);
      });
    });
  });
}
