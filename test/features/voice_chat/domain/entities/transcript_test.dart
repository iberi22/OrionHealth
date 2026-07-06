import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/domain/entities/transcript.dart';

void main() {
  group('Transcript', () {
    test('should support value equality', () {
      final now = DateTime.now();
      expect(
        Transcript(text: 'test', timestamp: now),
        Transcript(text: 'test', timestamp: now),
      );
    });

    test('copyWith should work correctly', () {
      final now = DateTime.now();
      final transcript = Transcript(text: 'test', timestamp: now);
      final updated = transcript.copyWith(text: 'updated');

      expect(updated.text, 'updated');
      expect(updated.timestamp, now);
      expect(updated.confidence, 1.0);
    });
  });
}
