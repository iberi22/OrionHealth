import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:health/health.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/health_data_import_service.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

class MockHealthDataImportService extends Mock implements HealthDataImportService {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  late HealthImportCubit cubit;
  late MockHealthDataImportService mockImportService;
  late MockVitalSignRepository mockVitalSignRepository;

  setUp(() {
    mockImportService = MockHealthDataImportService();
    mockVitalSignRepository = MockVitalSignRepository();
    cubit = HealthImportCubit(mockImportService, mockVitalSignRepository);
    registerFallbackValue(HealthDataSource.googleFit);
  });

  tearDown(() {
    cubit.close();
  });

  group('HealthImportCubit', () {
    test('initial state is HealthImportInitial', () {
      expect(cubit.state, isA<HealthImportInitial>());
    });

    test('checkAvailableSources emits [Loading, Ready] on success', () async {
      when(() => mockImportService.getAvailableSources())
          .thenAnswer((_) async => [HealthDataSource.googleFit]);

      final states = <HealthImportState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.checkAvailableSources();
      await Future.delayed(Duration.zero);

      expect(states, [
        isA<HealthImportLoading>(),
        isA<HealthImportReady>().having(
          (s) => s.availableSources,
          'availableSources',
          [HealthDataSource.googleFit],
        ),
      ]);
      await subscription.cancel();
    });

    test('checkAvailableSources emits [Loading, Error] on failure', () async {
      when(() => mockImportService.getAvailableSources())
          .thenThrow(Exception('Test error'));

      final states = <HealthImportState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.checkAvailableSources();
      await Future.delayed(Duration.zero);

      expect(states, [
        isA<HealthImportLoading>(),
        isA<HealthImportError>().having(
          (s) => s.message,
          'message',
          contains('Test error'),
        ),
      ]);
      await subscription.cancel();
    });

    test('importFromSource emits states and saves data on success', () async {
      when(() => mockImportService.requestAuthorization(any()))
          .thenAnswer((_) async => true);

      when(() => mockImportService.fetchSteps()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchDistance()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchHeartRate()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchSleep()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchBloodGlucose()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchBloodPressure()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchHeight()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchWeight()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchOxygenSaturation()).thenAnswer((_) async => []);

      when(() => mockImportService.convertToVitalSigns(any(), any()))
          .thenAnswer((_) async => []);

      when(() => mockVitalSignRepository.saveVitalSigns(any()))
          .thenAnswer((_) async => {});

      final states = <HealthImportState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.importFromSource(HealthDataSource.googleFit);
      await Future.delayed(Duration.zero);

      expect(states, [
        isA<HealthImportAuthenticating>(),
        isA<HealthImportImporting>(), // Step 1
        isA<HealthImportImporting>(), // Step 2
        isA<HealthImportImporting>(), // Step 3
        isA<HealthImportImporting>(), // Step 4
        isA<HealthImportImporting>(), // Step 5
        isA<HealthImportImporting>(), // Step 6
        isA<HealthImportImporting>(), // Step 7
        isA<HealthImportImporting>(), // Step 8
        isA<HealthImportSuccess>(),
      ]);
      await subscription.cancel();
    });

    test('importFromSource emits Error when authorization fails', () async {
      when(() => mockImportService.requestAuthorization(any()))
          .thenAnswer((_) async => false);

      final states = <HealthImportState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.importFromSource(HealthDataSource.googleFit);
      await Future.delayed(Duration.zero);

      expect(states, [
        isA<HealthImportAuthenticating>(),
        isA<HealthImportError>().having(
          (s) => s.message,
          'message',
          contains('Authorization denied'),
        ),
      ]);
      await subscription.cancel();
    });

    test('importFromSource emits Error on unexpected error', () async {
      when(() => mockImportService.requestAuthorization(any()))
          .thenThrow(Exception('Import crash'));

      final states = <HealthImportState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.importFromSource(HealthDataSource.googleFit);
      await Future.delayed(Duration.zero);

      expect(states, [
        isA<HealthImportAuthenticating>(),
        isA<HealthImportError>().having(
          (s) => s.message,
          'message',
          contains('Import crash'),
        ),
      ]);
      await subscription.cancel();
    });

    test('reset emits HealthImportInitial', () {
      cubit.emit(const HealthImportError('error'));
      cubit.reset();
      expect(cubit.state, isA<HealthImportInitial>());
    });
  });
}
