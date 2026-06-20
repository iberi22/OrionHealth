import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/models/vouch_model.dart';

void main() {
  final tDate = DateTime(2023, 6, 15);

  final tEntity = Vouch(
    id: 'v1',
    vouchedBy: 'doc2',
    targetDoctor: 'doc1',
    category: 'Clinical Excellence',
    timestamp: tDate,
  );

  final tModel = VouchModel(
    id: 'v1',
    vouchedBy: 'doc2',
    targetDoctor: 'doc1',
    category: 'Clinical Excellence',
    timestamp: tDate,
  );

  group('VouchModel', () {
    test('should be a subclass of Vouch entity', () {
      expect(tModel, isA<Vouch>());
    });

    test('fromJson should return a valid model', () {
      final jsonMap = <String, dynamic>{
        'id': 'v1',
        'vouchedBy': 'doc2',
        'targetDoctor': 'doc1',
        'category': 'Clinical Excellence',
        'timestamp': tDate.toIso8601String(),
      };

      final result = VouchModel.fromJson(jsonMap);

      expect(result.id, tModel.id);
      expect(result.vouchedBy, tModel.vouchedBy);
      expect(result.targetDoctor, tModel.targetDoctor);
      expect(result.category, tModel.category);
      expect(result.timestamp, tModel.timestamp);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tModel.toJson();

      expect(result['id'], 'v1');
      expect(result['vouchedBy'], 'doc2');
      expect(result['targetDoctor'], 'doc1');
      expect(result['category'], 'Clinical Excellence');
      expect(result['timestamp'], tDate.toIso8601String());
    });

    test('fromEntity should return a valid model', () {
      final result = VouchModel.fromEntity(tEntity);
      expect(result.id, tModel.id);
    });
  });
}
