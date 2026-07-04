import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/network/network_health/application/network_health_cubit.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_node.dart';
import 'package:orionhealth_health/features/network/network_health/domain/repositories/network_repository.dart';
import 'package:orionhealth_health/features/network/network_health/presentation/pages/network_health_page.dart';
import '../../../../../core/golden_test_utils.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}
class MockNetworkHealthCubit extends Mock implements NetworkHealthCubit {}

void main() {
  late MockNetworkRepository mockRepository;
  late NetworkHealthCubit cubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockRepository = MockNetworkRepository();
    getIt.registerSingleton<NetworkRepository>(mockRepository);

    cubit = NetworkHealthCubit(mockRepository);
    getIt.registerFactory<NetworkHealthCubit>(() => cubit);
  });

  tearDown(() {
    getIt.unregister<NetworkRepository>();
    getIt.unregister<NetworkHealthCubit>();
    cubit.close();
  });

  group('Network Health Page Golden Tests', () {
    testWidgets('NetworkHealthPage - Loaded State', (tester) async {
      final health = const NetworkHealth(
        status: NetworkStatus.healthy,
        activeNodes: 12,
        totalNodes: 15,
        averageLatency: 45.0,
        uptimePercentage: 99.9,
      );

      final nodes = [
        NetworkNode(
          id: '1',
          name: 'Primary Node',
          address: '192.168.1.1',
          status: NodeStatus.online,
          lastSeen: DateTime(2023, 1, 1),
        ),
        NetworkNode(
          id: '2',
          name: 'Secondary Node',
          address: '192.168.1.2',
          status: NodeStatus.offline,
          lastSeen: DateTime(2023, 1, 1),
        ),
      ];

      when(() => mockRepository.getNetworkHealth()).thenAnswer((_) async => health);
      when(() => mockRepository.getNodes()).thenAnswer((_) async => nodes);

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const NetworkHealthPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(NetworkHealthPage),
        matchesGoldenFile("../../../../../golden/reference/network_health_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
