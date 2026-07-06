import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/health_record/domain/usecases/save_record_usecase.dart';

class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}

class FakeMedicalRecord extends Fake implements MedicalRecord {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMedicalRecord());
  });

  late MockHealthRecordRepository mockRepository;
  late SaveRecordUseCase useCase;

  setUp(() {
    mockRepository = MockHealthRecordRepository();
    useCase = SaveRecordUseCase(mockRepository);
  });

  final tRecord = MedicalRecord(
    date: DateTime(2025, 1, 1),
    type: RecordType.labResult,
    summary: 'Normal',
  )..id = 1;

  test('should save record in the repository', () async {
    // arrange
    when(() => mockRepository.saveRecord(any()))
        .thenAnswer((_) async => {});

    // act
    await useCase(tRecord);

    // assert
    verify(() => mockRepository.saveRecord(tRecord)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
