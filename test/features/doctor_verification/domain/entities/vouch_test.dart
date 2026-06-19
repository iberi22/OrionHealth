import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';

void main() {
  group('Vouch entity', () {
    test('should support instantiation', () {
      final tDate = DateTime(2023, 1, 1);
      final vouch = Vouch(
        id: 'v1',
        vouchedBy: 'doc1',
        targetDoctor: 'doc2',
        category: 'Clinical',
        timestamp: tDate,
      );

      expect(vouch.id, 'v1');
      expect(vouch.vouchedBy, 'doc1');
      expect(vouch.targetDoctor, 'doc2');
      expect(vouch.category, 'Clinical');
      expect(vouch.timestamp, tDate);
    });
  });
}
