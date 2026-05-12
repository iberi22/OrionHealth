import 'package:isar/isar.dart';

part 'isar_chat_message.g.dart';

@collection
class IsarChatMessage {
  Id id = Isar.autoIncrement;

  /// Encrypted blob containing all ChatMessage fields
  late List<int> encryptedBlob;

  IsarChatMessage();
}
