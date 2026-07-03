import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/domain/repositories/network_repository.dart';
import 'package:orionhealth_health/features/network/network_health/domain/usecases/get_network_health.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  late GetNetworkHealth usecase;
  late MockNetworkRepository mockRepository;

  setUp(() {
    mockRepository = MockNetworkRepository();
    usecase = GetNetworkHealth(mockRepository);
  });

  const tNetworkHealth = NetworkHealth(
    status: NetworkStatus.healthy,
    activeNodes: 10,
    totalNodes: 10,
    averageLatency: 15.0,
    uptimePercentage: 100.0,
  );

  test('should get network health from the repository', () async {
    // arrange
    when(() => mockRepository.getNetworkHealth())
        .thenAnswer((_) async => tNetworkHealth);

    // act
    final result = await usecase();

    // assert
    expect(result, tNetworkHealth);
    verify(() => mockRepository.getNetworkHealth());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate error when repository fails', () async {
    // arrange
    when(() => mockRepository.getNetworkHealth())
        .thenThrow(Exception('Failed to get health'));

    // act & assert
    expect(() => usecase(), throwsException);
    verify(() => mockRepository.getNetworkHealth());
  });
}
