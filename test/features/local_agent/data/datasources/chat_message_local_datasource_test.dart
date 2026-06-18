import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/local_agent/data/datasources/chat_message_local_datasource.dart';
import 'package:orionhealth_health/features/local_agent/domain/chat_message.dart';

class MockIsar extends Mock implements Isar {}
class MockChatMessagesCollection extends Mock implements IsarCollection<ChatMessage> {}
class MockQueryBuilder extends Mock implements QueryBuilder<ChatMessage, ChatMessage, QWhereClause> {}

void main() {
  late MockIsar mockIsar;
  late MockChatMessagesCollection mockCollection;
  late ChatMessageLocalDataSource dataSource;

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockChatMessagesCollection();
    dataSource = ChatMessageLocalDataSource(mockIsar);

    when(() => mockIsar.chatMessages).thenReturn(mockCollection);
    // writeTxn is a Future<void> method, mocktail returns null by default
    // which causes 'type Null is not a subtype of type Future<void>'
    when(() => mockIsar.writeTxn(any())).thenAnswer((_) async {});
    when(() => mockCollection.put(any())).thenAnswer((_) async => 1);
  });

  group('ChatMessageLocalDataSource', () {
    final sampleMessage = ChatMessage(
      role: ChatRole.user,
      content: 'Test message',
      timestamp: DateTime(2026, 6, 18),
    );

    group('getMessages', () {
      test('returns messages sorted by timestamp descending with limit', () async {
        final mockQueryBuilder = MockQueryBuilder();
        when(() => mockCollection.where()).thenReturn(mockQueryBuilder);

        final results = <ChatMessage>[sampleMessage];
        when(() => mockQueryBuilder.sortByTimestampDesc()).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.limit(any())).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.findAll()).thenAnswer((_) async => results);

        final actual = await dataSource.getMessages(10);

        expect(actual, hasLength(1));
        expect(actual.first.content, equals('Test message'));
        verify(() => mockCollection.where()).called(1);
        verify(() => mockQueryBuilder.sortByTimestampDesc()).called(1);
        verify(() => mockQueryBuilder.limit(10)).called(1);
      });
    });

    group('saveMessage', () {
      test('saves message in a write transaction', () async {
        await dataSource.saveMessage(sampleMessage);

        verify(() => mockIsar.writeTxn(any())).called(1);
        verify(() => mockCollection.put(sampleMessage)).called(1);
      });
    });

    group('clearHistory', () {
      test('deletes all messages in a write transaction', () async {
        await dataSource.clearHistory();

        verify(() => mockIsar.writeTxn(any())).called(1);
      });
    });
  });
}
