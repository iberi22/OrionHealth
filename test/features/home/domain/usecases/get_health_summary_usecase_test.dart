import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/domain/usecases/get_health_summary_usecase.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  late GetHealthSummaryUseCase useCase;
  late MockVitalSignRepository mockRepository;

  setUp(() {
    mockRepository = MockVitalSignRepository();
    useCase = GetHealthSummaryUseCase(mockRepository);
  });

  test('should get latest vitals from repository', () async {
    // arrange
    final vitals = {
      VitalSignType.heartRate: VitalSign(
        type: VitalSignType.heartRate,
        value: 70,
        dateTime: DateTime.now(),
      ),
    };
    when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => vitals);

    // act
    final result = await useCase.execute();

    // assert
    expect(result, vitals);
    verify(() => mockRepository.getLatestVitals()).called(1);
  });
}
