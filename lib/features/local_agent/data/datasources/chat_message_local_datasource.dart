import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/chat_message.dart';

@lazySingleton
class ChatMessageLocalDataSource {
  final Isar _isar;
  ChatMessageLocalDataSource(this._isar);

  Future<List<ChatMessage>> getMessages(int limit) =>
      _isar.chatMessages.where().sortByTimestampDesc().limit(limit).findAll();

  Future<void> saveMessage(ChatMessage msg) =>
      _isar.writeTxn(() async => _isar.chatMessages.put(msg));

  Future<void> clearHistory() =>
      _isar.writeTxn(() async => _isar.chatMessages.where().deleteAll());
}
