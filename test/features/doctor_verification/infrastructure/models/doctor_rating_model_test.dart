import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/models/doctor_rating_model.dart';

void main() {
  final tDate = DateTime(2023, 6, 15);
  final tCategoriesMap = {'Clinical': 5, 'Bedside': 4};
  final tCategoriesJson = jsonEncode(tCategoriesMap);

  final tEntity = DoctorRating(
    id: 'r1',
    doctorId: 'doc1',
    patientId: 'p1',
    overallScore: 5,
    categoriesJson: tCategoriesJson,
    comment: 'Great doctor',
    createdAt: tDate,
    isAnonymous: false,
    verifiedVisit: true,
  );

  final tModel = DoctorRatingModel(
    id: 'r1',
    doctorId: 'doc1',
    patientId: 'p1',
    overallScore: 5,
    categoriesJson: tCategoriesJson,
    comment: 'Great doctor',
    createdAt: tDate,
    isAnonymous: false,
    verifiedVisit: true,
  );

  group('DoctorRatingModel', () {
    test('should be a subclass of DoctorRating entity', () {
      expect(tModel, isA<DoctorRating>());
    });

    test('fromJson should return a valid model', () {
      final jsonMap = <String, dynamic>{
        'id': 'r1',
        'doctorId': 'doc1',
        'patientId': 'p1',
        'overallScore': 5,
        'categoriesJson': tCategoriesJson,
        'comment': 'Great doctor',
        'createdAt': tDate.toIso8601String(),
        'isAnonymous': false,
        'verifiedVisit': true,
      };

      final result = DoctorRatingModel.fromJson(jsonMap);

      expect(result.id, tModel.id);
      expect(result.doctorId, tModel.doctorId);
      expect(result.overallScore, tModel.overallScore);
      expect(result.categoriesJson, tModel.categoriesJson);
      expect(result.createdAt, tModel.createdAt);
    });

    test('fromJson should handle categoriesJson as Map', () {
      final jsonMap = <String, dynamic>{
        'id': 'r1',
        'doctorId': 'doc1',
        'overallScore': 5,
        'categoriesJson': tCategoriesMap,
        'createdAt': tDate.toIso8601String(),
      };

      final result = DoctorRatingModel.fromJson(jsonMap);
      expect(result.categoriesJson, tCategoriesJson);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tModel.toJson();

      expect(result['id'], 'r1');
      expect(result['doctorId'], 'doc1');
      expect(result['overallScore'], 5);
      expect(result['categoriesJson'], tCategoriesJson);
      expect(result['createdAt'], tDate.toIso8601String());
    });

    test('fromEntity should return a valid model', () {
      final result = DoctorRatingModel.fromEntity(tEntity);
      expect(result.id, tModel.id);
      expect(result.doctorId, tModel.doctorId);
    });
  });
}
