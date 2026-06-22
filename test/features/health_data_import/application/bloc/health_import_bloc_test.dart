import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_data_import/application/bloc/health_import_bloc.dart';
import 'package:orionhealth_health/features/health_data_import/application/bloc/health_import_event.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/health_data_import_service.dart';
import 'package:orionhealth_health/features/health_data_import/domain/usecases/health_import_usecases.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';

class MockGetAvailableSourcesUseCase extends Mock implements GetAvailableSourcesUseCase {}
class MockRequestHealthAuthUseCase extends Mock implements RequestHealthAuthUseCase {}
class MockHealthDataImportService extends Mock implements HealthDataImportService {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  late HealthImportBloc bloc;
  late MockGetAvailableSourcesUseCase mockGetAvailableSources;
  late MockRequestHealthAuthUseCase mockRequestHealthAuth;
  late MockHealthDataImportService mockImportService;
  late MockVitalSignRepository mockVitalSignRepository;

  setUp(() {
    mockGetAvailableSources = MockGetAvailableSourcesUseCase();
    mockRequestHealthAuth = MockRequestHealthAuthUseCase();
    mockImportService = MockHealthDataImportService();
    mockVitalSignRepository = MockVitalSignRepository();

    bloc = HealthImportBloc(
      mockGetAvailableSources,
      mockRequestHealthAuth,
      mockImportService,
      mockVitalSignRepository,
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

    test('ResetImport emits HealthImportInitial', () async {
      bloc.add(const ResetImport());
      await expectLater(bloc.stream, emits(const HealthImportInitial()));
    });
  });
}
