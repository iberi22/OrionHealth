import 'package:isar/isar.dart';

part 'chat_message.g.dart';

enum ChatRole {
  user,
  assistant,
}

@Collection()
class ChatMessage {
  final Id id;

  @Enumerated(EnumType.name)
  final ChatRole role;

  String content;

  final DateTime timestamp;

  final List<String> citations;

  ChatMessage({
    this.id = Isar.autoIncrement,
    required this.role,
    required this.content,
    required this.timestamp,
    this.citations = const [],
  });
}
