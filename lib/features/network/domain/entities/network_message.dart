import 'package:isar/isar.dart';

part 'network_message.g.dart';

enum MessageType {
  text,
  data,
  handshake,
  system,
}

@collection
class NetworkMessage {
  Id id = Isar.autoIncrement;

  @Index()
  late String senderId;

  @Index()
  late String receiverId;

  late String content;

  @Index()
  late DateTime timestamp;

  @Enumerated(EnumType.name)
  late MessageType type;

  String? signature;

  NetworkMessage({
    this.id = Isar.autoIncrement,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.signature,
  });
}
