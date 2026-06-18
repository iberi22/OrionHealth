import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:orionhealth_health/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetRecentActivityUseCase useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetRecentActivityUseCase(mockRepository);
  });

  final tActivities = [
    ActivityItem(
      id: '1',
      title: 'Activity 1',
      timestamp: DateTime(2023, 1, 1),
      type: ActivityType.vitalCheck,
    ),
  ];

  test('should get recent activity from the repository', () async {
    // arrange
    when(() => mockRepository.getRecentActivity())
        .thenAnswer((_) async => tActivities);

    // act
    final result = await useCase();

    // assert
    expect(result, tActivities);
    verify(() => mockRepository.getRecentActivity());
    verifyNoMoreInteractions(mockRepository);
  });
}
