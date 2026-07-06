import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/usecases/get_all_vital_signs_usecase.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  late GetAllVitalSignsUseCase useCase;
  late MockVitalSignRepository mockRepository;

  setUp(() {
    mockRepository = MockVitalSignRepository();
    useCase = GetAllVitalSignsUseCase(mockRepository);
  });

  group('GetAllVitalSignsUseCase', () {
    test('should return all vitals from repository', () async {
      final tVitals = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 70,
          unit: 'bpm',
          dateTime: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => tVitals);

      final result = await useCase();

      expect(result, tVitals);
      verify(() => mockRepository.getAllVitalSigns()).called(1);
    });
  });
}
