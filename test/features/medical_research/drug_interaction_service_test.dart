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

  group('MedicalStandardsService - Drug Interaction Analysis', () {
    test('handles empty drug list', () async {
      final interactions = await standardsService.checkDrugInteractions([]);
      expect(interactions, isEmpty);
    });

    test('handles single drug (no interaction possible)', () async {
      final warfarin = LocalRxnormEntry(code: '855332', displayName: 'Warfarin', drugClass: 'Anticoagulant');
      when(() => mockProvider.getRxnormForCode('855332')).thenReturn(warfarin);

      final interactions = await standardsService.checkDrugInteractions(['855332']);
      expect(interactions, isEmpty);
    });

    test('handles unknown drug codes', () async {
      when(() => mockProvider.getRxnormForCode('unknown')).thenReturn(null);

      final interactions = await standardsService.checkDrugInteractions(['unknown', '855332']);
      expect(interactions, isEmpty);
    });

    test('detects Major interaction: Warfarin + Aspirin', () async {
      final warfarin = LocalRxnormEntry(code: '855332', displayName: 'Warfarin', drugClass: 'Anticoagulant');
      final aspirin = LocalRxnormEntry(code: '1191', displayName: 'Aspirin', drugClass: 'NSAID');

      when(() => mockProvider.getRxnormForCode('855332')).thenReturn(warfarin);
      when(() => mockProvider.getRxnormForCode('1191')).thenReturn(aspirin);

      final interactions = await standardsService.checkDrugInteractions(['855332', '1191']);

      expect(interactions, hasLength(1));
      expect(interactions.first, contains('Major Interaction'));
      expect(interactions.first, contains('Warfarin + Aspirin'));
    });

    test('detects Moderate interaction: Lisinopril + Spironolactone', () async {
      final lisinopril = LocalRxnormEntry(code: '1', displayName: 'Lisinopril', drugClass: 'ACE Inhibitor');
      final spiro = LocalRxnormEntry(code: '2', displayName: 'Spironolactone', drugClass: 'Diuretic');

      when(() => mockProvider.getRxnormForCode('1')).thenReturn(lisinopril);
      when(() => mockProvider.getRxnormForCode('2')).thenReturn(spiro);

      final interactions = await standardsService.checkDrugInteractions(['1', '2']);

      expect(interactions, hasLength(1));
      expect(interactions.first, contains('Moderate Interaction'));
      expect(interactions.first, contains('ACE Inhibitor + Spironolactone'));
    });

    test('detects Moderate interaction: Metformin + Contrast Medium', () async {
      final metformin = LocalRxnormEntry(code: 'M', displayName: 'Metformin', drugClass: 'Biguanide');
      final contrast = LocalRxnormEntry(code: 'C', displayName: 'Contrast Medium', drugClass: 'Diagnostic');

      when(() => mockProvider.getRxnormForCode('M')).thenReturn(metformin);
      when(() => mockProvider.getRxnormForCode('C')).thenReturn(contrast);

      final interactions = await standardsService.checkDrugInteractions(['M', 'C']);

      expect(interactions, hasLength(1));
      expect(interactions.first, contains('Moderate Interaction'));
      expect(interactions.first, contains('Metformin + Contrast'));
    });

    test('detects Contraindicated: SSRI + MAOI classes', () async {
      final fluoxetine = LocalRxnormEntry(code: '3', displayName: 'Fluoxetine', drugClass: 'SSRI');
      final phenelzine = LocalRxnormEntry(code: '4', displayName: 'Phenelzine', drugClass: 'MAOI');

      when(() => mockProvider.getRxnormForCode('3')).thenReturn(fluoxetine);
      when(() => mockProvider.getRxnormForCode('4')).thenReturn(phenelzine);

      final interactions = await standardsService.checkDrugInteractions(['3', '4']);

      expect(interactions, hasLength(1));
      expect(interactions.first, contains('Contraindicated'));
      expect(interactions.first, contains('SSRI + MAOI'));
    });

    test('handles multi-drug scenarios (3+ medications)', () async {
      // Warfarin (Anticoagulant), Aspirin (NSAID), and Ibuprofen (NSAID)
      // Interactions:
      // 1. Warfarin + Aspirin (Major)
      // 2. Warfarin + Ibuprofen (Moderate, via class NSAID + Anticoagulant)

      final warfarin = LocalRxnormEntry(code: 'W', displayName: 'Warfarin', drugClass: 'Anticoagulant');
      final aspirin = LocalRxnormEntry(code: 'A', displayName: 'Aspirin', drugClass: 'NSAID');
      final ibuprofen = LocalRxnormEntry(code: 'I', displayName: 'Ibuprofen', drugClass: 'NSAID');

      when(() => mockProvider.getRxnormForCode('W')).thenReturn(warfarin);
      when(() => mockProvider.getRxnormForCode('A')).thenReturn(aspirin);
      when(() => mockProvider.getRxnormForCode('I')).thenReturn(ibuprofen);

      final interactions = await standardsService.checkDrugInteractions(['W', 'A', 'I']);

      // Interactions: Warfarin+Aspirin (Major) AND Warfarin+Ibuprofen (Moderate)
      expect(interactions.length, equals(2));
      expect(interactions.any((i) => i.contains('Major Interaction: Warfarin + Aspirin')), isTrue);
      expect(interactions.any((i) => i.contains('Moderate Interaction: NSAID + Anticoagulant')), isTrue);
    });

    test('detects multiple distinct interactions in one list', () async {
      final warfarin = LocalRxnormEntry(code: 'W', displayName: 'Warfarin', drugClass: 'Anticoagulant');
      final aspirin = LocalRxnormEntry(code: 'A', displayName: 'Aspirin', drugClass: 'NSAID');
      final fluoxetine = LocalRxnormEntry(code: 'F', displayName: 'Fluoxetine', drugClass: 'SSRI');
      final phenelzine = LocalRxnormEntry(code: 'P', displayName: 'Phenelzine', drugClass: 'MAOI');

      when(() => mockProvider.getRxnormForCode('W')).thenReturn(warfarin);
      when(() => mockProvider.getRxnormForCode('A')).thenReturn(aspirin);
      when(() => mockProvider.getRxnormForCode('F')).thenReturn(fluoxetine);
      when(() => mockProvider.getRxnormForCode('P')).thenReturn(phenelzine);

      final interactions = await standardsService.checkDrugInteractions(['W', 'A', 'F', 'P']);

      // Should find Warfarin+Aspirin AND SSRI+MAOI
      expect(interactions.any((i) => i.contains('Warfarin + Aspirin')), isTrue);
      expect(interactions.any((i) => i.contains('SSRI + MAOI')), isTrue);
    });
  });
}
