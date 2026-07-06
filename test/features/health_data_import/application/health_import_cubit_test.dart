import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/usecases/health_import_usecases.dart';

class MockGetAvailableSourcesUseCase extends Mock implements GetAvailableSourcesUseCase {}
class MockRequestHealthAuthUseCase extends Mock implements RequestHealthAuthUseCase {}
class MockImportHealthDataUseCase extends Mock implements ImportHealthDataUseCase {}

void main() {
  late HealthImportCubit cubit;
  late MockGetAvailableSourcesUseCase mockGetAvailableSourcesUseCase;
  late MockRequestHealthAuthUseCase mockRequestHealthAuthUseCase;
  late MockImportHealthDataUseCase mockImportHealthDataUseCase;

  setUpAll(() {
    registerFallbackValue(HealthDataSource.googleFit);
  });

  setUp(() {
    mockGetAvailableSourcesUseCase = MockGetAvailableSourcesUseCase();
    mockRequestHealthAuthUseCase = MockRequestHealthAuthUseCase();
    mockImportHealthDataUseCase = MockImportHealthDataUseCase();
    cubit = HealthImportCubit(
      mockGetAvailableSourcesUseCase,
      mockRequestHealthAuthUseCase,
      mockImportHealthDataUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('HealthImportCubit', () {
    test('initial state is HealthImportInitial', () {
      expect(cubit.state, isA<HealthImportInitial>());
    });

    test('checkAvailableSources emits [Loading, Ready] on success', () async {
      when(() => mockGetAvailableSourcesUseCase())
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
      when(() => mockGetAvailableSourcesUseCase())
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
      when(() => mockRequestHealthAuthUseCase(any()))
          .thenAnswer((_) async => true);

      when(() => mockImportHealthDataUseCase(any()))
          .thenAnswer((_) => Stream.fromIterable([
            const ImportProgress(
              currentStep: 'Step 1',
              totalSteps: 2,
              currentStepNum: 1,
              importedCount: 0,
            ),
            const ImportProgress(
              currentStep: 'Completed',
              totalSteps: 2,
              currentStepNum: 2,
              importedCount: 10,
              isCompleted: true,
            ),
          ]));

      final states = <HealthImportState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.importFromSource(HealthDataSource.googleFit);
      await Future.delayed(Duration.zero);

      expect(states, [
        isA<HealthImportAuthenticating>(),
        isA<HealthImportImporting>().having((s) => s.currentStep, 'currentStep', 'Step 1'),
        isA<HealthImportSuccess>().having((s) => s.result.importedCount, 'importedCount', 10),
      ]);
      await subscription.cancel();
    });

    test('importFromSource emits Error when authorization fails', () async {
      when(() => mockRequestHealthAuthUseCase(any()))
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
      when(() => mockRequestHealthAuthUseCase(any()))
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
