import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class FakeVitalSign extends Fake implements VitalSign {}

void main() {
  late MockVitalSignRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeVitalSign());
  });

  setUp(() {
    mockRepository = MockVitalSignRepository();
  });

  group('VitalSignRepository Interface', () {
    test('can be mocked and called', () async {
      final tVital = VitalSign(
        type: VitalSignType.heartRate,
        value: 70,
        unit: 'bpm',
        dateTime: DateTime.now(),
      );

      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => [tVital]);
      when(() => mockRepository.saveVitalSign(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveVitalSigns(any())).thenAnswer((_) async {});
      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {VitalSignType.heartRate: tVital});

      final vitals = await mockRepository.getAllVitalSigns();
      await mockRepository.saveVitalSign(tVital);
      await mockRepository.saveVitalSigns([tVital]);
      final latest = await mockRepository.getLatestVitals();

      expect(vitals, [tVital]);
      expect(latest[VitalSignType.heartRate], tVital);

      verify(() => mockRepository.getAllVitalSigns()).called(1);
      verify(() => mockRepository.saveVitalSign(tVital)).called(1);
      verify(() => mockRepository.saveVitalSigns([tVital])).called(1);
      verify(() => mockRepository.getLatestVitals()).called(1);
    });
  });
}
