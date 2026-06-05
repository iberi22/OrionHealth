import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/services/medical_guidelines_service.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('MedicalGuidelinesService Tests', () {
    late MedicalGuidelinesService service;

    setUp(() {
      service = MedicalGuidelinesService();
    });

    test('getGuidelinesForConditions - returns guidelines for single condition', () {
      final guidelines = service.getGuidelinesForConditions(['E11']); // Diabetes Type 2
      expect(guidelines, isNotEmpty);
      expect(guidelines.any((g) => g.code == 'ADA-2024'), isTrue);
    });

    test('getGuidelinesForConditions - returns guidelines for multiple conditions', () {
      final guidelines = service.getGuidelinesForConditions(['E11', 'I10']); // Diabetes + HTN
      expect(guidelines, isNotEmpty);
      expect(guidelines.any((g) => g.code == 'ADA-2024'), isTrue);
      expect(guidelines.any((g) => g.code == 'AHA-2017'), isTrue);
    });

    test('getGuidelinesForConditions - deduplicates guidelines', () {
      // ADA-2024 is listed for both E10 and E11 in medical_standards
      final guidelines = service.getGuidelinesForConditions(['E10', 'E11']);
      final ada2024Matches = guidelines.where((g) => g.code == 'ADA-2024').length;
      expect(ada2024Matches, 1);
    });

    test('getGuidelinesForConditions - empty list for unknown condition', () {
      final guidelines = service.getGuidelinesForConditions(['UNKNOWN_CODE']);
      expect(guidelines, isEmpty);
    });

    test('getGuidelinesForConditions - empty list for empty input', () {
      final guidelines = service.getGuidelinesForConditions([]);
      expect(guidelines, isEmpty);
    });

    test('getGuidelinesForLabs - matches diabetes labs', () {
      final guidelines = service.getGuidelinesForLabs(['4548-4']); // HbA1c
      expect(guidelines.any((g) => g.code == 'ADA-2024'), isTrue);
      expect(guidelines.any((g) => g.code == 'CLSI-2017'), isTrue);
    });

    test('getGuidelinesForLabs - matches cholesterol labs', () {
      final guidelines = service.getGuidelinesForLabs(['2093-3']); // Total Cholesterol
      expect(guidelines.any((g) => g.code == 'AHA-2018'), isTrue);
    });

    test('getGuidelinesForLabs - returns only general lab reference for unknown labs', () {
      final guidelines = service.getGuidelinesForLabs(['UNKNOWN-LAB']);
      expect(guidelines.length, 1);
      expect(guidelines.first.code, 'CLSI-2017');
    });

    test('getGuidelineByCode - returns correct guideline', () {
      final guideline = service.getGuidelineByCode('ADA-2024');
      expect(guideline, isNotNull);
      expect(guideline?.displayName, contains('Diabetes'));
    });

    test('getGuidelineByCode - returns null for invalid code', () {
      final guideline = service.getGuidelineByCode('INVALID-CODE');
      expect(guideline, isNull);
    });
  });
}
