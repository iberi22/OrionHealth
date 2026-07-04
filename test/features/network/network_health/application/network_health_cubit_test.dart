import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/network_health/application/network_health_cubit.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/domain/repositories/network_repository.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  late NetworkHealthCubit cubit;
  late MockNetworkRepository mockRepository;

  const tNetworkHealth = NetworkHealth(
    status: NetworkStatus.healthy,
    activeNodes: 5,
    totalNodes: 10,
    averageLatency: 20.0,
    uptimePercentage: 99.0,
  );

  setUp(() {
    mockRepository = MockNetworkRepository();
    cubit = NetworkHealthCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('NetworkHealthCubit', () {
    test('initial state should be NetworkHealthState()', () {
      expect(cubit.state, const NetworkHealthState());
    });

    test('loadNetworkHealth emits loading and then loaded when successful', () async {
      when(() => mockRepository.getNetworkHealth()).thenAnswer((_) async => tNetworkHealth);
      when(() => mockRepository.getNodes()).thenAnswer((_) async => []);

      expectLater(
        cubit.stream,
        emitsInOrder([
          const NetworkHealthState(status: NetworkHealthStatus.loading),
          const NetworkHealthState(
            status: NetworkHealthStatus.loaded,
            networkHealth: tNetworkHealth,
            nodes: [],
          ),
        ]),
      );

      await cubit.loadNetworkHealth();
    });

    test('loadNetworkHealth emits loading and then error when fails', () async {
      when(() => mockRepository.getNetworkHealth()).thenThrow(Exception('Failed to load'));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const NetworkHealthState(status: NetworkHealthStatus.loading),
          const NetworkHealthState(
            status: NetworkHealthStatus.error,
            errorMessage: 'Exception: Failed to load',
          ),
        ]),
      );

      await cubit.loadNetworkHealth();
    });

    test('connectToNode calls repository and reloads', () async {
      when(() => mockRepository.connectNode(any())).thenAnswer((_) async => {});
      when(() => mockRepository.getNetworkHealth()).thenAnswer((_) async => tNetworkHealth);
      when(() => mockRepository.getNodes()).thenAnswer((_) async => []);

      await cubit.connectToNode('node1');

      verify(() => mockRepository.connectNode('node1')).called(1);
      verify(() => mockRepository.getNetworkHealth()).called(1);
    });
  });
}
