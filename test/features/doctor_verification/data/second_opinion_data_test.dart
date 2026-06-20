import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/second_opinion.dart';

void main() {
  group('SecondOpinion Data Tests', () {
    test('SecondOpinionRequest correctly stores data', () {
      final now = DateTime.now();
      final request = SecondOpinionRequest(
        id: 'req1',
        patientId: 'pat1',
        primaryDoctorId: 'doc1',
        symptoms: 'Headache',
        documents: ['path/to/doc.pdf'],
        createdAt: now,
      );

      expect(request.id, 'req1');
      expect(request.patientId, 'pat1');
      expect(request.primaryDoctorId, 'doc1');
      expect(request.symptoms, 'Headache');
      expect(request.documents, contains('path/to/doc.pdf'));
      expect(request.createdAt, now);
    });

    test('SecondOpinionResponse correctly stores data', () {
      final now = DateTime.now();
      final response = SecondOpinionResponse(
        id: 'res1',
        requestId: 'req1',
        reviewerDoctorId: 'doc2',
        recommendation: 'Rest',
        confidence: 0.9,
        respondedAt: now,
      );

      expect(response.id, 'res1');
      expect(response.requestId, 'req1');
      expect(response.reviewerDoctorId, 'doc2');
      expect(response.recommendation, 'Rest');
      expect(response.confidence, 0.9);
      expect(response.respondedAt, now);
    });
  });
}
