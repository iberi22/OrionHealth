import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/domain/entities/home_health_summary.dart';
import 'package:orionhealth_health/features/home/domain/repositories/home_repository.dart';
import 'package:orionhealth_health/features/home/domain/usecases/get_health_summary_usecase.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late GetHealthSummaryUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetHealthSummaryUseCase(mockRepository);
  });

  final tSummary = HomeHealthSummary(
    latestVitals: [
      VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: DateTime(2026, 6, 17),
        unit: 'bpm',
      ),
    ],
    upcomingAppointments: [],
    medicationCount: 3,
  );

  group('GetHealthSummaryUseCase', () {
    test('should return HomeHealthSummary from the repository', () async {
      // arrange
      when(() => mockRepository.getHealthSummary())
          .thenAnswer((_) async => tSummary);

      // act
      final result = await useCase();

      // assert
      expect(result, equals(tSummary));
      verify(() => mockRepository.getHealthSummary()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository exceptions', () async {
      // arrange
      when(() => mockRepository.getHealthSummary())
          .thenThrow(Exception('Repository error'));

      // act & assert
      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.getHealthSummary()).called(1);
    });
  });
}
