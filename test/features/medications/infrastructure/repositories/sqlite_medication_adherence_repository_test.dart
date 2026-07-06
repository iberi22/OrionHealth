import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication_adherence.dart';
import 'package:orionhealth_health/features/medications/infrastructure/datasources/adherence_sqlite_datasource.dart';
import 'package:orionhealth_health/features/medications/infrastructure/repositories/sqlite_medication_adherence_repository.dart';
import 'package:sqflite/sqflite.dart';

class MockAdherenceSqliteDatasource extends Mock implements AdherenceSqliteDatasource {}
class MockDatabase extends Mock implements Database {}

void main() {
  late MockAdherenceSqliteDatasource mockDatasource;
  late MockDatabase mockDatabase;
  late SqliteMedicationAdherenceRepository repository;

  setUp(() {
    mockDatasource = MockAdherenceSqliteDatasource();
    mockDatabase = MockDatabase();
    repository = SqliteMedicationAdherenceRepository(mockDatasource);

    when(() => mockDatasource.database).thenAnswer((_) async => mockDatabase);
  });

  group('SqliteMedicationAdherenceRepository', () {
    test('saveAdherence should insert when id is null', () async {
      final adherence = MedicationAdherence(
        medicationId: 1,
        scheduledTime: DateTime.now(),
        status: AdherenceStatus.scheduled,
      );

      when(() => mockDatabase.insert(any(), any())).thenAnswer((_) async => 1);

      await repository.saveAdherence(adherence);

      verify(() => mockDatabase.insert(
            AdherenceSqliteDatasource.tableAdherence,
            any(),
          )).called(1);
    });

    test('getAdherenceForMedication should return list', () async {
      final now = DateTime.now();
      when(() => mockDatabase.query(
            any(),
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
            orderBy: any(named: 'orderBy'),
          )).thenAnswer((_) async => [
            {
              AdherenceSqliteDatasource.columnId: 1,
              AdherenceSqliteDatasource.columnMedicationId: 1,
              AdherenceSqliteDatasource.columnScheduledTime: now.toIso8601String(),
              AdherenceSqliteDatasource.columnStatus: 'taken',
              AdherenceSqliteDatasource.columnNotes: 'Took it with water',
            }
          ]);

      final results = await repository.getAdherenceForMedication(1);

      expect(results.length, 1);
      expect(results.first.status, AdherenceStatus.taken);
      expect(results.first.medicationId, 1);
    });
  });
}
