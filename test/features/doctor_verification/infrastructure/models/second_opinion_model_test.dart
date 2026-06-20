import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/second_opinion.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/models/second_opinion_model.dart';

void main() {
  final tDate = DateTime(2023, 6, 15);

  group('SecondOpinionRequestModel', () {
    final tEntity = SecondOpinionRequest(
      id: 'req1',
      patientId: 'p1',
      primaryDoctorId: 'doc1',
      symptoms: 'Symptoms',
      documents: ['doc1.pdf'],
      createdAt: tDate,
    );

    final tModel = SecondOpinionRequestModel(
      id: 'req1',
      patientId: 'p1',
      primaryDoctorId: 'doc1',
      symptoms: 'Symptoms',
      documents: ['doc1.pdf'],
      createdAt: tDate,
    );

    test('should be a subclass of SecondOpinionRequest entity', () {
      expect(tModel, isA<SecondOpinionRequest>());
    });

    test('fromJson should return a valid model', () {
      final jsonMap = <String, dynamic>{
        'id': 'req1',
        'patientId': 'p1',
        'primaryDoctorId': 'doc1',
        'symptoms': 'Symptoms',
        'documents': ['doc1.pdf'],
        'createdAt': tDate.toIso8601String(),
      };

      final result = SecondOpinionRequestModel.fromJson(jsonMap);

      expect(result.id, tModel.id);
      expect(result.patientId, tModel.patientId);
      expect(result.primaryDoctorId, tModel.primaryDoctorId);
      expect(result.symptoms, tModel.symptoms);
      expect(result.documents, tModel.documents);
      expect(result.createdAt, tModel.createdAt);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tModel.toJson();

      expect(result['id'], 'req1');
      expect(result['patientId'], 'p1');
      expect(result['primaryDoctorId'], 'doc1');
      expect(result['symptoms'], 'Symptoms');
      expect(result['documents'], ['doc1.pdf']);
      expect(result['createdAt'], tDate.toIso8601String());
    });

    test('fromEntity should return a valid model', () {
      final result = SecondOpinionRequestModel.fromEntity(tEntity);
      expect(result.id, tModel.id);
    });
  });

  group('SecondOpinionResponseModel', () {
    final tEntity = SecondOpinionResponse(
      id: 'res1',
      requestId: 'req1',
      reviewerDoctorId: 'doc2',
      recommendation: 'Recommendation',
      confidence: 0.9,
      respondedAt: tDate,
    );

    final tModel = SecondOpinionResponseModel(
      id: 'res1',
      requestId: 'req1',
      reviewerDoctorId: 'doc2',
      recommendation: 'Recommendation',
      confidence: 0.9,
      respondedAt: tDate,
    );

    test('should be a subclass of SecondOpinionResponse entity', () {
      expect(tModel, isA<SecondOpinionResponse>());
    });

    test('fromJson should return a valid model', () {
      final jsonMap = <String, dynamic>{
        'id': 'res1',
        'requestId': 'req1',
        'reviewerDoctorId': 'doc2',
        'recommendation': 'Recommendation',
        'confidence': 0.9,
        'respondedAt': tDate.toIso8601String(),
      };

      final result = SecondOpinionResponseModel.fromJson(jsonMap);

      expect(result.id, tModel.id);
      expect(result.requestId, tModel.requestId);
      expect(result.reviewerDoctorId, tModel.reviewerDoctorId);
      expect(result.recommendation, tModel.recommendation);
      expect(result.confidence, tModel.confidence);
      expect(result.respondedAt, tModel.respondedAt);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tModel.toJson();

      expect(result['id'], 'res1');
      expect(result['requestId'], 'req1');
      expect(result['reviewerDoctorId'], 'doc2');
      expect(result['recommendation'], 'Recommendation');
      expect(result['confidence'], 0.9);
      expect(result['respondedAt'], tDate.toIso8601String());
    });

    test('fromEntity should return a valid model', () {
      final result = SecondOpinionResponseModel.fromEntity(tEntity);
      expect(result.id, tModel.id);
    });
  });
}
