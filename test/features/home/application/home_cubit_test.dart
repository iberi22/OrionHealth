import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/home/application/home_cubit.dart';
import 'package:orionhealth_health/features/home/application/home_state.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/medical_indexing_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockMedicalIndexingService extends Mock implements MedicalIndexingService {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late HomeCubit cubit;
  late MockVitalSignRepository mockVitalSignRepository;
  late MockMedicalIndexingService mockMedicalIndexingService;
  late MockUserProfileRepository mockUserProfileRepository;
  late StreamController<bool> indexingStatusController;

  setUp(() {
    mockVitalSignRepository = MockVitalSignRepository();
    mockMedicalIndexingService = MockMedicalIndexingService();
    mockUserProfileRepository = MockUserProfileRepository();
    indexingStatusController = StreamController<bool>.broadcast();

    when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => {});
    when(() => mockMedicalIndexingService.hasIndexed).thenReturn(true);
    when(() => mockMedicalIndexingService.statusStream).thenAnswer((_) => indexingStatusController.stream);
  });

  tearDown(() {
    indexingStatusController.close();
  });

  test('initial state is correct', () {
    when(() => mockMedicalIndexingService.hasIndexed).thenReturn(true);
    cubit = HomeCubit(
      mockVitalSignRepository,
      mockMedicalIndexingService,
      mockUserProfileRepository,
    );
    // HomeCubit starts isLoadingVitals: true because it calls _loadVitals in constructor
    expect(cubit.state, const HomeState(isLoadingVitals: true));
  });

  test('should load vitals on init', () async {
    final Map<VitalSignType, VitalSign?> vitals = {
      VitalSignType.heartRate: VitalSign(
        type: VitalSignType.heartRate,
        value: 70,
        dateTime: DateTime.now(),
      ),
    };
    when(() => mockVitalSignRepository.getLatestVitals()).thenAnswer((_) async => vitals);

    cubit = HomeCubit(
      mockVitalSignRepository,
      mockMedicalIndexingService,
      mockUserProfileRepository,
    );

    // Give it time to run _init
    await Future.delayed(Duration.zero);

    expect(cubit.state.latestVitals, vitals);
    expect(cubit.state.isLoadingVitals, false);
  });

  test('should update isIndexing based on hasIndexed and statusStream', () async {
    when(() => mockMedicalIndexingService.hasIndexed).thenReturn(false);

    cubit = HomeCubit(
      mockVitalSignRepository,
      mockMedicalIndexingService,
      mockUserProfileRepository,
    );

    expect(cubit.state.isIndexing, true);

    indexingStatusController.add(true);
    await Future.delayed(Duration.zero);

    expect(cubit.state.isIndexing, false);
  });

  test('retryIndexing should update state correctly on success', () async {
    when(() => mockMedicalIndexingService.indexAll(force: true))
        .thenAnswer((_) async => const IndexingResult(total: 10, indexed: 10, errors: 0));

    cubit = HomeCubit(
      mockVitalSignRepository,
      mockMedicalIndexingService,
      mockUserProfileRepository,
    );

    final future = cubit.retryIndexing();
    expect(cubit.state.isIndexing, true);

    await future;

    expect(cubit.state.isIndexing, false);
    expect(cubit.state.indexingError, false);
  });

  test('retryIndexing should update state correctly on error', () async {
    when(() => mockMedicalIndexingService.indexAll(force: true))
        .thenAnswer((_) async => const IndexingResult(total: 10, indexed: 0, errors: 10));

    cubit = HomeCubit(
      mockVitalSignRepository,
      mockMedicalIndexingService,
      mockUserProfileRepository,
    );

    await cubit.retryIndexing();

    expect(cubit.state.isIndexing, false);
    expect(cubit.state.indexingError, true);
  });
}
