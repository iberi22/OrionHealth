import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/vitals/application/vitals_cubit.dart';
import 'package:orionhealth_health/features/vitals/application/vitals_state.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}

class FakeVitalSign extends Fake implements VitalSign {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVitalSign());
    registerFallbackValue(const <VitalSign>[]);
  });
  late MockVitalSignRepository repository;
  late VitalsCubit cubit;

  setUp(() {
    repository = MockVitalSignRepository();
    cubit = VitalsCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('VitalsCubit', () {
    final tVitals = [
      VitalSign(type: VitalSignType.heartRate, value: 72, dateTime: DateTime.now(), unit: 'bpm'),
      VitalSign(type: VitalSignType.temperature, value: 36.5, dateTime: DateTime.now(), unit: '°C'),
    ];

    test('initial state is VitalsInitial', () {
      expect(cubit.state, isA<VitalsInitial>());
    });

    group('loadVitals', () {
      test('emits loading then loaded on success', () async {
        when(() => repository.getAllVitalSigns()).thenAnswer((_) async => tVitals);

        expectLater(cubit.stream, emitsInOrder([
          isA<VitalsLoading>(),
          isA<VitalsLoaded>(),
        ]));
        await cubit.loadVitals();
      });

      test('emits loading then error on failure', () async {
        when(() => repository.getAllVitalSigns()).thenThrow(Exception('db error'));

        expectLater(cubit.stream, emitsInOrder([
          isA<VitalsLoading>(),
          isA<VitalsError>(),
        ]));
        await cubit.loadVitals();
      });
    });

    group('loadLatestVitals', () {
      test('emits loading then latestLoaded on success', () async {
        when(() => repository.getLatestVitals()).thenAnswer((_) async => {VitalSignType.heartRate: tVitals[0]});

        expectLater(cubit.stream, emitsInOrder([
          isA<VitalsLoading>(),
          isA<VitalsLatestLoaded>(),
        ]));
        await cubit.loadLatestVitals();
      });
    });

    group('saveVitalSign', () {
      test('saves and reloads', () async {
        when(() => repository.saveVitalSign(any())).thenAnswer((_) async {});
        when(() => repository.getAllVitalSigns()).thenAnswer((_) async => tVitals);

        expectLater(cubit.stream, emitsInOrder([
          isA<VitalsLoading>(),
          isA<VitalsLoaded>(),
        ]));
        await cubit.saveVitalSign(tVitals.first);
      });
    });

    group('saveVitalSigns', () {
      test('saves batch and reloads', () async {
        when(() => repository.saveVitalSigns(any())).thenAnswer((_) async {});
        when(() => repository.getAllVitalSigns()).thenAnswer((_) async => tVitals);

        expectLater(cubit.stream, emitsInOrder([
          isA<VitalsLoading>(),
          isA<VitalsLoaded>(),
        ]));
        await cubit.saveVitalSigns(tVitals);
      });

      test('emits error on failure', () async {
        when(() => repository.saveVitalSigns(any())).thenThrow(Exception('save error'));

        expectLater(cubit.stream, emitsInOrder([
          isA<VitalsError>(),
        ]));
        await cubit.saveVitalSigns(tVitals);
      });
    });

    group('saveVitalSign', () {
      test('emits error on failure', () async {
        when(() => repository.saveVitalSign(any())).thenThrow(Exception('save error'));

        expectLater(cubit.stream, emitsInOrder([
          isA<VitalsError>(),
        ]));
        await cubit.saveVitalSign(tVitals.first);
      });
    });
  });

  group('VitalSign.formattedValue', () {
    test('formats heart rate correctly', () {
      final vs = VitalSign(type: VitalSignType.heartRate, value: 72, dateTime: DateTime.now());
      expect(vs.formattedValue, '72 bpm');
    });

    test('formats temperature correctly', () {
      final vs = VitalSign(type: VitalSignType.temperature, value: 36.5, dateTime: DateTime.now());
      expect(vs.formattedValue, '36.5°C');
    });

    test('formats spO2 correctly', () {
      final vs = VitalSign(type: VitalSignType.spO2, value: 98, dateTime: DateTime.now());
      expect(vs.formattedValue, '98%');
    });

    test('formats steps correctly', () {
      final vs = VitalSign(type: VitalSignType.steps, value: 8423, dateTime: DateTime.now());
      expect(vs.formattedValue, '8423 steps');
    });
  });
}
