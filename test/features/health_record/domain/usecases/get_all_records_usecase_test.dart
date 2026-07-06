import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/health_record/domain/usecases/get_all_records_usecase.dart';

class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}

void main() {
  late MockHealthRecordRepository mockRepository;
  late GetAllRecordsUseCase useCase;

  setUp(() {
    mockRepository = MockHealthRecordRepository();
    useCase = GetAllRecordsUseCase(mockRepository);
  });

  final tRecords = [
    MedicalRecord(
      date: DateTime(2025, 1, 1),
      type: RecordType.labResult,
      summary: 'Normal',
    )..id = 1,
  ];

  test('should get all records from the repository', () async {
    // arrange
    when(() => mockRepository.getAllRecords())
        .thenAnswer((_) async => tRecords);

    // act
    final result = await useCase();

    // assert
    expect(result, tRecords);
    verify(() => mockRepository.getAllRecords()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
