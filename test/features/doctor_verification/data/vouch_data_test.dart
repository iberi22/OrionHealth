import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';

void main() {
  group('Vouch Data Tests', () {
    test('Vouch entity correctly stores data', () {
      final now = DateTime.now();
      final vouch = Vouch(
        id: 'v1',
        vouchedBy: 'doc1',
        targetDoctor: 'doc2',
        category: 'Excellence',
        timestamp: now,
      );

      expect(vouch.id, 'v1');
      expect(vouch.vouchedBy, 'doc1');
      expect(vouch.targetDoctor, 'doc2');
      expect(vouch.category, 'Excellence');
      expect(vouch.timestamp, now);
    });
  });
}
