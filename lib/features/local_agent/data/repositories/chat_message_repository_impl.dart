import '../../domain/chat_message.dart';
import '../datasources/chat_message_local_datasource.dart';

class ChatMessageRepository {
  final ChatMessageLocalDataSource _localDataSource;
  ChatMessageRepository(this._localDataSource);

  Future<List<ChatMessage>> getMessages(int limit) => _localDataSource.getMessages(limit);
  Future<void> saveMessage(ChatMessage msg) => _localDataSource.saveMessage(msg);
  Future<void> clearHistory() => _localDataSource.clearHistory();
}
