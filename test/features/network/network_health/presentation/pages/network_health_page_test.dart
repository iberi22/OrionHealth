import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/domain/repositories/network_repository.dart';
import 'package:orionhealth_health/features/network/network_health/presentation/pages/network_health_page.dart';
import 'package:orionhealth_health/features/network/network_health/presentation/widgets/network_status_card.dart';
import 'package:orionhealth_health/features/network/network_health/presentation/widgets/node_list_item.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  late MockNetworkRepository mockRepository;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockRepository = MockNetworkRepository();
    getIt.registerSingleton<NetworkRepository>(mockRepository);
  });

  tearDown(() {
    getIt.unregister<NetworkRepository>();
  });

  const tNetworkHealth = NetworkHealth(
    status: NetworkStatus.healthy,
    activeNodes: 5,
    totalNodes: 10,
    averageLatency: 20.0,
    uptimePercentage: 99.0,
  );

  testWidgets('should render loading indicator then content', (tester) async {
    when(() => mockRepository.getNetworkHealth()).thenAnswer((_) async => tNetworkHealth);
    when(() => mockRepository.getNodes()).thenAnswer((_) async => []);

    await tester.pumpWidget(const MaterialApp(home: NetworkHealthPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(NetworkStatusCard), findsOneWidget);
    expect(find.text('Network Nodes'), findsOneWidget);
  });

  testWidgets('should render error message when repository fails', (tester) async {
    when(() => mockRepository.getNetworkHealth()).thenThrow(Exception('Failed to load health'));

    await tester.pumpWidget(const MaterialApp(home: NetworkHealthPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Error: Exception: Failed to load health'), findsOneWidget);
  });
}
