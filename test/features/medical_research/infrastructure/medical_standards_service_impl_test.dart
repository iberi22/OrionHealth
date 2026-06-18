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
  });

  group('MedicalStandardsServiceImpl', () {
    group('lookupIcd10', () {
      test('returns Icd10Code when diagnosis matches', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.searchIcd10('diabetes')).thenReturn([
          LocalIcd10Entry(
            code: 'E11',
            displayName: 'Type 2 Diabetes Mellitus',
            category: 'Endocrine',
            synonyms: ['Diabetes mellitus type 2', 'NIDDM'],
          ),
        ]);

        final result = await standardsService.lookupIcd10('diabetes');

        expect(result, isNotNull);
        expect(result!.code, 'E11');
        expect(result.displayName, 'Type 2 Diabetes Mellitus');
        expect(result.category, 'Endocrine');
        expect(result.synonyms, contains('NIDDM'));
      });

      test('returns null when no match found', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.searchIcd10('nonexistent'))
            .thenReturn([]);

        final result = await standardsService.lookupIcd10('nonexistent');

        expect(result, isNull);
      });

      test('initializes provider if not already initialized', () async {
        when(() => mockProvider.isInitialized).thenReturn(false);
        when(() => mockProvider.initialize()).thenAnswer((_) async {});
        when(() => mockProvider.searchIcd10('hypertension')).thenReturn([
          LocalIcd10Entry(
            code: 'I10',
            displayName: 'Essential Hypertension',
            category: 'Cardiovascular',
          ),
        ]);

        final result = await standardsService.lookupIcd10('hypertension');

        expect(result, isNotNull);
        expect(result!.code, 'I10');
        verify(() => mockProvider.initialize()).called(1);
      });
    });

    group('lookupSnomed', () {
      test('returns SnomedConcept when term matches', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.searchSnomed('asthma')).thenReturn([
          LocalSnomedEntry(
            code: '195967001',
            displayName: 'Asthma',
            fullySpecifiedName: 'Asthma (disorder)',
            semanticTag: 'disorder',
            icd10Mappings: ['J45'],
          ),
        ]);

        final result = await standardsService.lookupSnomed('asthma');

        expect(result, isNotNull);
        expect(result!.code, '195967001');
        expect(result.displayName, 'Asthma');
        expect(result.semanticTag, 'disorder');
        expect(result.icd10Mappings, contains('J45'));
      });

      test('returns null when no term match', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.searchSnomed('unknown'))
            .thenReturn([]);

        final result = await standardsService.lookupSnomed('unknown');

        expect(result, isNull);
      });
    });

    group('searchGuidelines', () {
      test('returns guidelines when ICD-10 code found', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.searchIcd10('asthma')).thenReturn([
          LocalIcd10Entry(
            code: 'J45',
            displayName: 'Asthma',
            category: 'Respiratory',
          ),
        ]);
        when(() => mockProvider.getGuidelinesForCondition('J45')).thenReturn([
          ClinicalGuidelineReference(
            code: 'GINA-2024',
            displayName: 'Global Initiative for Asthma',
            organization: 'GINA',
            url: 'https://ginasthma.org',
            lastUpdated: DateTime(2024, 1),
            applicableConditions: ['J45'],
          ),
        ]);

        final results = await standardsService.searchGuidelines('asthma');

        expect(results.length, 1);
        expect(results[0].displayName, 'Global Initiative for Asthma');
        expect(results[0].organization, 'GINA');
      });

      test('returns empty list when ICD-10 code not found', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.searchIcd10('unknown'))
            .thenReturn([]);

        final results = await standardsService.searchGuidelines('unknown');

        expect(results, isEmpty);
      });
    });

    group('checkDrugInteractions', () {
      test('returns known interactions between warfarin and aspirin', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.getRxnormForCode('rx:202421'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:202421',
              displayName: 'Warfarin',
              genericName: 'Warfarin',
              drugClass: 'Anticoagulant',
            ));
        when(() => mockProvider.getRxnormForCode('rx:1191'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:1191',
              displayName: 'Aspirin',
              genericName: 'Aspirin',
              drugClass: 'NSAID',
            ));

        final interactions = await standardsService
            .checkDrugInteractions(['rx:202421', 'rx:1191']);

        expect(interactions, isNotEmpty);
        expect(interactions.first, contains('Warfarin'));
        expect(interactions.first, contains('Aspirin'));
        expect(interactions.first, contains('bleeding'));
      });

      test('returns known interactions between SSRI and MAOI', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.getRxnormForCode('rx:123'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:123',
              displayName: 'Fluoxetine',
              genericName: 'Fluoxetine',
              drugClass: 'SSRI',
            ));
        when(() => mockProvider.getRxnormForCode('rx:456'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:456',
              displayName: 'Phenelzine',
              genericName: 'Phenelzine',
              drugClass: 'MAOI',
            ));

        final interactions = await standardsService
            .checkDrugInteractions(['rx:123', 'rx:456']);

        expect(interactions, isNotEmpty);
        expect(interactions.first, contains('SSRI'));
        expect(interactions.first, contains('MAOI'));
      });

      test('returns empty list when no interactions found', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.getRxnormForCode('rx:111'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:111',
              displayName: 'Vitamin C',
            ));
        when(() => mockProvider.getRxnormForCode('rx:222'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:222',
              displayName: 'Vitamin D',
            ));

        final interactions = await standardsService
            .checkDrugInteractions(['rx:111', 'rx:222']);

        expect(interactions, isEmpty);
      });

      test('handles unknown RxNorm codes', () async {
        when(() => mockProvider.isInitialized).thenReturn(true);
        when(() => mockProvider.getRxnormForCode('rx:unknown'))
            .thenReturn(null);
        when(() => mockProvider.getRxnormForCode('rx:1191'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:1191',
              displayName: 'Aspirin',
            ));

        final interactions = await standardsService
            .checkDrugInteractions(['rx:unknown', 'rx:1191']);

        expect(interactions, isEmpty);
      });

      test('initializes provider if not initialized', () async {
        when(() => mockProvider.isInitialized).thenReturn(false);
        when(() => mockProvider.initialize()).thenAnswer((_) async {});
        when(() => mockProvider.getRxnormForCode('rx:1191'))
            .thenReturn(LocalRxnormEntry(
              code: 'rx:1191',
              displayName: 'Aspirin',
            ));

        final interactions = await standardsService
            .checkDrugInteractions(['rx:1191']);

        expect(interactions, isEmpty);
        verify(() => mockProvider.initialize()).called(1);
      });
    });
  });
}
