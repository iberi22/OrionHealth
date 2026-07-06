import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/application/bloc/health_import_bloc.dart';
import 'package:orionhealth_health/features/health_data_import/application/bloc/health_import_event.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/usecases/health_import_usecases.dart';

class MockGetAvailableSourcesUseCase extends Mock implements GetAvailableSourcesUseCase {}
class MockRequestHealthAuthUseCase extends Mock implements RequestHealthAuthUseCase {}
class MockImportHealthDataUseCase extends Mock implements ImportHealthDataUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(HealthDataSource.googleFit);
  });

  late HealthImportBloc bloc;
  late MockGetAvailableSourcesUseCase mockGetAvailableSources;
  late MockRequestHealthAuthUseCase mockRequestHealthAuth;
  late MockImportHealthDataUseCase mockImportHealthData;

  setUp(() {
    mockGetAvailableSources = MockGetAvailableSourcesUseCase();
    mockRequestHealthAuth = MockRequestHealthAuthUseCase();
    mockImportHealthData = MockImportHealthDataUseCase();

    bloc = HealthImportBloc(
      mockGetAvailableSources,
      mockRequestHealthAuth,
      mockImportHealthData,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('HealthImportBloc', () {
    test('initial state is HealthImportInitial', () {
      expect(bloc.state, const HealthImportInitial());
    });

    test('CheckAvailableSources emits [Loading, Ready] on success', () async {
      when(() => mockGetAvailableSources()).thenAnswer((_) async => [HealthDataSource.googleFit]);

      final expected = [
        const HealthImportLoading(),
        const HealthImportReady(
          availableSources: [HealthDataSource.googleFit],
          availability: {
            HealthDataSource.googleFit: true,
            HealthDataSource.appleHealth: false,
            HealthDataSource.samsungHealth: false,
          },
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const CheckAvailableSources());
    });

    test('ImportFromSource emits error if auth fails', () async {
      when(() => mockRequestHealthAuth(any())).thenAnswer((_) async => false);

      final expected = [
        const HealthImportAuthenticating(HealthDataSource.googleFit),
        const HealthImportError('Authorization denied. Please grant permission to access health data.'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const ImportFromSource(HealthDataSource.googleFit));
    });

    test('ImportFromSource emits states and result on success', () async {
      when(() => mockRequestHealthAuth(any())).thenAnswer((_) async => true);
      when(() => mockImportHealthData(any())).thenAnswer((_) => Stream.fromIterable([
        const ImportProgress(currentStep: 'Step 1', totalSteps: 2, currentStepNum: 1, importedCount: 5),
        const ImportProgress(currentStep: 'Done', totalSteps: 2, currentStepNum: 2, importedCount: 10, isCompleted: true),
      ]));

      final expected = [
        const HealthImportAuthenticating(HealthDataSource.googleFit),
        isA<HealthImportImporting>().having((s) => s.importedCount, 'importedCount', 5),
        isA<HealthImportSuccess>().having((s) => s.result.importedCount, 'importedCount', 10),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const ImportFromSource(HealthDataSource.googleFit));
    });

    test('ResetImport emits HealthImportInitial', () async {
      bloc.add(const ResetImport());
      await expectLater(bloc.stream, emits(const HealthImportInitial()));
    });
  });
}
