import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/domain/entities/network_message.dart';

void main() {
  group('NetworkMessage', () {
    test('should create NetworkMessage with correct values', () {
      final timestamp = DateTime.now();
      final message = NetworkMessage(
        senderId: 'sender123',
        receiverId: 'receiver456',
        content: 'Hello',
        timestamp: timestamp,
        type: MessageType.text,
        signature: 'sig',
      );

      expect(message.senderId, 'sender123');
      expect(message.receiverId, 'receiver456');
      expect(message.content, 'Hello');
      expect(message.timestamp, timestamp);
      expect(message.type, MessageType.text);
      expect(message.signature, 'sig');
    });
  });
}
