import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/network/network_health/application/network_health_cubit.dart';
import 'package:orionhealth_health/features/network/network_health/application/network_health_state.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_node.dart';
import 'package:orionhealth_health/features/network/network_health/presentation/pages/network_health_page.dart';
import '../../../../../core/golden_test_utils.dart';

class MockNetworkHealthCubit extends Mock implements NetworkHealthCubit {}

void main() {
  late MockNetworkHealthCubit mockCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockCubit = MockNetworkHealthCubit();
    // Use when stubbing for loadNetworkStatus to avoid errors
    when(() => mockCubit.loadNetworkStatus()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    // Stub stream to avoid _InheritedProviderScope error
    when(() => mockCubit.stream).thenAnswer((_) => const Stream<NetworkHealthState>.empty());
  });

  group('NetworkHealthPage Golden Tests', () {
    testWidgets('Loaded state', (tester) async {
      final health = NetworkHealth(
        status: NetworkStatus.healthy,
        activeNodes: 10,
        totalNodes: 12,
        averageLatency: 45.0,
        uptimePercentage: 99.9,
      );
      final nodes = [
        NetworkNode(
          id: '1',
          name: 'Node 1',
          address: '1.1.1.1',
          status: NodeStatus.online,
          lastSeen: DateTime(2025, 1, 1),
        ),
        NetworkNode(
          id: '2',
          name: 'Node 2',
          address: '2.2.2.2',
          status: NodeStatus.offline,
          lastSeen: DateTime(2025, 1, 1),
        ),
      ];

      when(() => mockCubit.state).thenReturn(NetworkHealthState(
        status: NetworkHealthStatus.loaded,
        health: health,
        nodes: nodes,
      ));

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<NetworkHealthCubit>.value(
          value: mockCubit,
          child: const NetworkHealthPage(),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(NetworkHealthPage),
        matchesGoldenFile("goldens/network_health_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Loading state', (tester) async {
      when(() => mockCubit.state).thenReturn(const NetworkHealthState(
        status: NetworkHealthStatus.loading,
      ));

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<NetworkHealthCubit>.value(
          value: mockCubit,
          child: const NetworkHealthPage(),
        ),
      ));
      // Not using pumpAndSettle because of CircularProgressIndicator
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(NetworkHealthPage),
        matchesGoldenFile("goldens/network_health_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Error state', (tester) async {
      when(() => mockCubit.state).thenReturn(const NetworkHealthState(
        status: NetworkHealthStatus.error,
        errorMessage: 'Connection failed',
      ));

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<NetworkHealthCubit>.value(
          value: mockCubit,
          child: const NetworkHealthPage(),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(NetworkHealthPage),
        matchesGoldenFile("goldens/network_health_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
