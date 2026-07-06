import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/usecases/save_vital_signs_usecase.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  late SaveVitalSignsUseCase useCase;
  late MockVitalSignRepository mockRepository;

  setUp(() {
    mockRepository = MockVitalSignRepository();
    useCase = SaveVitalSignsUseCase(mockRepository);
  });

  group('SaveVitalSignsUseCase', () {
    test('should save vitals in repository', () async {
      final tVitals = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 70,
          unit: 'bpm',
          dateTime: DateTime.now(),
        ),
      ];

      when(() => mockRepository.saveVitalSigns(any())).thenAnswer((_) async {});

      await useCase(tVitals);

      verify(() => mockRepository.saveVitalSigns(tVitals)).called(1);
    });
  });
}
