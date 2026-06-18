import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetDashboardStatsUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetDashboardStatsUseCase(mockRepository);
  });

  final tStats = DashboardStats(
    totalMedications: 5,
    reportsCount: 2,
    lastVitalCheck: DateTime(2023, 1, 1),
  );

  test('should get stats from the repository', () async {
    // arrange
    when(() => mockRepository.getDashboardStats())
        .thenAnswer((_) async => tStats);

    // act
    final result = await useCase();

    // assert
    expect(result, tStats);
    verify(() => mockRepository.getDashboardStats());
    verifyNoMoreInteractions(mockRepository);
  });
}
