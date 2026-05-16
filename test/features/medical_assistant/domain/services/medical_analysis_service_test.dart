import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/medical_analysis_service.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MedicalAnalysisService Compatibility Tests', () {
    late MedicalAnalysisService service;

    setUp(() {
      service = MedicalAnalysisService();
    });

    test('analyzeLabWithConfidence - Normal Glucose', () async {
      final response = await service.analyzeLabWithConfidence(
        labCode: '2345-7', // Glucose
        value: 85.0,
      );

      expect(response.confidence, greaterThanOrEqualTo(0.8));
      expect(response.explanation, contains('dentro del rango normal'));
      expect(response.possibleInterpretation, contains('dentro de los rangos normales'));
    });

    test('analyzeLabWithConfidence - High Glucose (Diabetes)', () async {
      final response = await service.analyzeLabWithConfidence(
        labCode: '4548-4', // HbA1c
        value: 12.0,
      );

      expect(response.confidence, greaterThanOrEqualTo(0.9));
      expect(response.possibleInterpretation, contains('diabetes o prediabetes'));
    });

    test('analyzeVitalWithConfidence - Critical BP', () async {
      final response = await service.analyzeVitalWithConfidence(
        vitalType: 'systolic',
        value: 190.0,
        relatedVitals: {'systolic': 190.0, 'diastolic': 130.0},
      );

      expect(response.confidence, 0.95);
      expect(response.explanation, contains('CRISIS'));
      expect(response.doctorRecommendation, contains('EMERGENCIA'));
    });

    test('analyzeSymptomsWithConfidence - Fatigue', () async {
      final response = await service.analyzeSymptomsWithConfidence(
        symptoms: ['fatiga'],
        currentMedications: [],
      );

      expect(response.explanation, contains('PODRÍA ESTAR RELACIONADO CON'));
      expect(response.suggestedExams, contains('Hemograma completo'));
    });
  });
}
