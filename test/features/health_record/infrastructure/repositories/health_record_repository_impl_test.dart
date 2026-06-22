import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/repositories/health_record_repository_impl.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionMedicalRecord extends IsarCollection<MedicalRecord> {}
class MockIsarCollection extends Mock implements IsarCollectionMedicalRecord {}

class FakeMedicalRecord extends Fake implements MedicalRecord {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late HealthRecordRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeMedicalRecord());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = HealthRecordRepositoryImpl(mockIsar);

    when(() => mockIsar.medicalRecords).thenReturn(mockCollection);
  });

  group('HealthRecordRepositoryImpl', () {
    test('saveRecord puts record in collection', () async {
      final record = MedicalRecord(summary: 'Test summary');
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveRecord(record);

      verify(() => mockCollection.put(record)).called(1);
    });
  });
}
