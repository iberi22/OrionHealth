import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/domain/repositories/medication_repository.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}
class FakeMedication extends Fake implements Medication {}

void main() {
  late MockMedicationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeMedication());
  });

  setUp(() {
    mockRepository = MockMedicationRepository();
  });

  group('MedicationRepository', () {
    final now = DateTime.now();
    final tMedication = Medication(
      name: 'Ibuprofeno',
      dosage: '400mg',
      frequency: 'Cada 8 horas',
      startDate: now,
      isActive: true,
      notes: 'Tomar con comida',
    );

    test('should return all medications', () async {
      when(() => mockRepository.getAllMedications())
          .thenAnswer((_) async => [tMedication]);

      final medications = await mockRepository.getAllMedications();

      expect(medications, [tMedication]);
      verify(() => mockRepository.getAllMedications()).called(1);
    });

    test('should save a medication', () async {
      when(() => mockRepository.saveMedication(any()))
          .thenAnswer((_) async => {});

      await mockRepository.saveMedication(tMedication);

      verify(() => mockRepository.saveMedication(tMedication)).called(1);
    });

    test('should delete a medication', () async {
      when(() => mockRepository.deleteMedication(any()))
          .thenAnswer((_) async => {});

      await mockRepository.deleteMedication(1);

      verify(() => mockRepository.deleteMedication(1)).called(1);
    });

    test('should return empty list when no medications', () async {
      when(() => mockRepository.getAllMedications())
          .thenAnswer((_) async => []);

      final medications = await mockRepository.getAllMedications();

      expect(medications, isEmpty);
      verify(() => mockRepository.getAllMedications()).called(1);
    });

    test('should throw when repository fails', () async {
      when(() => mockRepository.getAllMedications())
          .thenThrow(Exception('DB error'));

      expect(
        () => mockRepository.getAllMedications(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
