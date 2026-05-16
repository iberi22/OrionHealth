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

      expect(response.confidence, greaterThanOrEqualTo(0.3));
      expect(response.explanation, contains('VALOR DE LABORATORIO'));
    });

    test('analyzeLabWithConfidence - High Glucose (Diabetes)', () async {
      final response = await service.analyzeLabWithConfidence(
        labCode: '17861-6', // HbA1c (actual code in full_loinc.json)
        value: 12.0,
      );

      expect(response.confidence, greaterThanOrEqualTo(0.2));
      expect(response.explanation, contains('VALOR DE LABORATORIO'));
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
