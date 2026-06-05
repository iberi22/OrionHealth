import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_standards_service_impl.dart';

class MockMedicalContextProvider extends Mock implements MedicalContextProvider {}

void main() {
  late MockMedicalContextProvider mockProvider;
  late MedicalStandardsServiceImpl standardsService;

  setUp(() {
    mockProvider = MockMedicalContextProvider();
    standardsService = MedicalStandardsServiceImpl(mockProvider);

    when(() => mockProvider.isInitialized).thenReturn(true);
    when(() => mockProvider.initialize()).thenAnswer((_) async => {});
  });

  group('MedicalStandardsService', () {
    test('lookupIcd10 returns result if found', () async {
      final entry = LocalIcd10Entry(code: 'E11', displayName: 'Diabetes', category: 'Endocrine', synonyms: const []);
      when(() => mockProvider.searchIcd10('diabetes')).thenReturn([entry]);

      final result = await standardsService.lookupIcd10('diabetes');

      expect(result!.code, equals('E11'));
      expect(result!.displayName, equals('Diabetes'));
    });

    test('checkDrugInteractions detects Warfarin + Aspirin', () async {
      final warfarin = LocalRxnormEntry(code: '855332', displayName: 'Warfarin', drugClass: 'Anticoagulant');
      final aspirin = LocalRxnormEntry(code: '1191', displayName: 'Aspirin', drugClass: 'NSAID');

      when(() => mockProvider.searchMedications('warfarin')).thenReturn([warfarin]);
      when(() => mockProvider.searchMedications('aspirin')).thenReturn([aspirin]);

      final interactions = await standardsService.checkDrugInteractions(['855332', '1191']);

      expect(interactions.any((i) => i.contains('Warfarin + Aspirin')), isTrue);
    });

    test('checkDrugInteractions detects class-based interaction (SSRI + MAOI)', () async {
      final fluoxetine = LocalRxnormEntry(code: '1', displayName: 'Fluoxetine', drugClass: 'SSRI');
      final phenelzine = LocalRxnormEntry(code: '2', displayName: 'Phenelzine', drugClass: 'MAOI');

      when(() => mockProvider.searchMedications('fluoxetine')).thenReturn([fluoxetine]);
      when(() => mockProvider.searchMedications('phenelzine')).thenReturn([phenelzine]);

      final interactions = await standardsService.checkDrugInteractions(['1', '2']);

      expect(interactions.any((i) => i.contains('SSRI + MAOI')), isTrue);
    });
   group('searchGuidelines', () {
    test('calls getGuidelinesForCondition when ICD-10 is found', () async {
      final entry = LocalIcd10Entry(code: 'E11', displayName: 'Diabetes', category: 'Endocrine', synonyms: const []);
      when(() => mockProvider.searchIcd10('diabetes')).thenReturn([entry]);
      when(() => mockProvider.getGuidelinesForCondition('E11')).thenReturn([]);

      await standardsService.searchGuidelines('diabetes');

      verify(() => mockProvider.getGuidelinesForCondition('E11')).called(1);
    });
  });
});
}
