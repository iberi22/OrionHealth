import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/application/bloc/vital_sign_bloc.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}

class FakeVitalSign extends Fake implements VitalSign {}

void main() {
  late VitalSignBloc vitalSignBloc;
  late MockVitalSignRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeVitalSign());
  });

  setUp(() {
    mockRepository = MockVitalSignRepository();
    vitalSignBloc = VitalSignBloc(mockRepository);
  });

  tearDown(() {
    vitalSignBloc.close();
  });

  group('VitalSignBloc', () {
    final tVital = VitalSign(
      type: VitalSignType.heartRate,
      value: 70,
      dateTime: DateTime(2023, 1, 1),
    );
    final tVitals = [tVital];
    final tLatest = {VitalSignType.heartRate: tVital};

    test('initial state should be VitalSignInitial', () {
      expect(vitalSignBloc.state, const VitalSignInitial());
    });

    group('LoadVitalSigns', () {
      test('emits [Loading, Loaded] when success', () async {
        when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => tVitals);

        vitalSignBloc.add(LoadVitalSigns());

        expectLater(
          vitalSignBloc.stream,
          emitsInOrder([
            const VitalSignLoading(),
            VitalSignLoaded(tVitals),
          ]),
        );
      });

      test('emits [Loading, Error] when fails', () async {
        when(() => mockRepository.getAllVitalSigns()).thenThrow(Exception('DB Error'));

        vitalSignBloc.add(LoadVitalSigns());

        expectLater(
          vitalSignBloc.stream,
          emitsInOrder([
            const VitalSignLoading(),
            const VitalSignError('Exception: DB Error'),
          ]),
        );
      });
    });

    group('LoadLatestVitals', () {
      test('emits [Loading, LatestLoaded] when success', () async {
        when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => tLatest);

        vitalSignBloc.add(LoadLatestVitals());

        expectLater(
          vitalSignBloc.stream,
          emitsInOrder([
            const VitalSignLoading(),
            VitalSignLatestLoaded(tLatest),
          ]),
        );
      });
    });

    group('SaveVitalSign', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.saveVitalSign(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => tVitals);

        vitalSignBloc.add(SaveVitalSign(tVital));

        await untilCalled(() => mockRepository.saveVitalSign(any()));
        verify(() => mockRepository.saveVitalSign(tVital)).called(1);
      });
    });

    group('SaveVitalSigns', () {
      test('calls repository and reloads', () async {
        when(() => mockRepository.saveVitalSigns(any())).thenAnswer((_) async {});
        when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => tVitals);

        vitalSignBloc.add(SaveVitalSigns(tVitals));

        await untilCalled(() => mockRepository.saveVitalSigns(any()));
        verify(() => mockRepository.saveVitalSigns(tVitals)).called(1);
      });
    });
  });
}
