import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/second_opinion.dart';

void main() {
  group('SecondOpinion entities', () {
    final tDate = DateTime(2023, 1, 1);

    test('SecondOpinionRequest should support instantiation', () {
      final request = SecondOpinionRequest(
        id: 'req1',
        patientId: 'p1',
        primaryDoctorId: 'doc1',
        symptoms: 'Fever',
        documents: ['doc.pdf'],
        createdAt: tDate,
      );

      expect(request.id, 'req1');
      expect(request.patientId, 'p1');
      expect(request.primaryDoctorId, 'doc1');
      expect(request.symptoms, 'Fever');
      expect(request.documents, ['doc.pdf']);
      expect(request.createdAt, tDate);
    });

    test('SecondOpinionResponse should support instantiation', () {
      final response = SecondOpinionResponse(
        id: 'res1',
        requestId: 'req1',
        reviewerDoctorId: 'doc2',
        recommendation: 'Rest',
        confidence: 0.9,
        respondedAt: tDate,
      );

      expect(response.id, 'res1');
      expect(response.requestId, 'req1');
      expect(response.reviewerDoctorId, 'doc2');
      expect(response.recommendation, 'Rest');
      expect(response.confidence, 0.9);
      expect(response.respondedAt, tDate);
    });
  });
}
