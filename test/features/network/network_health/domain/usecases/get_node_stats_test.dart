import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/node_stats.dart';
import 'package:orionhealth_health/features/network/network_health/domain/repositories/network_repository.dart';
import 'package:orionhealth_health/features/network/network_health/domain/usecases/get_node_stats.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  late GetNodeStats usecase;
  late MockNetworkRepository mockRepository;

  setUp(() {
    mockRepository = MockNetworkRepository();
    usecase = GetNodeStats(mockRepository);
  });

  const tNodeId = 'node-123';
  const tNodeStats = NodeStats(
    nodeId: tNodeId,
    cpuUsage: 10.0,
    memoryUsage: 20.0,
    diskUsage: 30.0,
    uptime: Duration(days: 1),
  );

  test('should get node stats from the repository', () async {
    // arrange
    when(() => mockRepository.getNodeStats(any()))
        .thenAnswer((_) async => tNodeStats);

    // act
    final result = await usecase(tNodeId);

    // assert
    expect(result, tNodeStats);
    verify(() => mockRepository.getNodeStats(tNodeId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate error when repository fails', () async {
    // arrange
    when(() => mockRepository.getNodeStats(any()))
        .thenThrow(Exception('Failed to get stats'));

    // act & assert
    expect(() => usecase(tNodeId), throwsException);
    verify(() => mockRepository.getNodeStats(tNodeId));
  });
}
