import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/network/network_health/presentation/pages/network_health_page.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_health.dart';
import 'package:orionhealth_health/features/network/network_health/domain/entities/network_node.dart';
import 'package:orionhealth_health/features/network/network_health/domain/repositories/network_repository.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/video_recorder.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockNetworkRepository mockRepository;

  setUpAll(() async {
    await di.configureDependencies();
  });

  setUp(() {
    mockRepository = MockNetworkRepository();
    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<NetworkRepository>(mockRepository);
  });

  tearDown(() {
    di.getIt.unregister<NetworkRepository>();
  });

  Widget createNetworkTestWidget(Widget home) {
    return MaterialApp(
      home: home,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('Network Health Flow - True E2E Tests', () {
    testWidgets('E2E: Navigation to Network Health Page and Basic Verification', (WidgetTester tester) async {
      const networkHealth = NetworkHealth(
        status: NetworkStatus.healthy,
        activeNodes: 12,
        totalNodes: 15,
        averageLatency: 45.0,
        uptimePercentage: 99.9,
      );

      final nodes = [
        NetworkNode(
          id: 'node_1',
          name: 'Main Node',
          address: '192.168.1.100',
          status: NodeStatus.online,
          lastSeen: DateTime.now(),
        ),
        NetworkNode(
          id: 'node_2',
          name: 'Backup Node',
          address: '192.168.1.101',
          status: NodeStatus.offline,
          lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];

      when(() => mockRepository.getNetworkHealth()).thenAnswer((_) async => networkHealth);
      when(() => mockRepository.getNodes()).thenAnswer((_) async => nodes);

      // Start from User Profile to test navigation
      await tester.pumpWidget(createNetworkTestWidget(const UserProfilePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'network', '01_user_profile');

      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // Navigate to Network Health
      final networkTile = find.text(l10n.networkHealth);
      await tester.scrollUntilVisible(networkTile, 100);
      await tester.tap(networkTile);
      await tester.pumpAndSettle();

      // Verify Network Health Page is shown
      expect(find.byType(NetworkHealthPage), findsOneWidget);
      expect(find.text('Network Health'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'network', '02_network_loaded');

      // Verify Stats
      expect(find.textContaining('12'), findsWidgets); // Active nodes
      expect(find.textContaining('99.9%'), findsOneWidget);

      // Verify Nodes
      expect(find.text('Main Node'), findsOneWidget);
      expect(find.text('Backup Node'), findsOneWidget);

      // Interaction: Pull to refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      verify(() => mockRepository.getNetworkHealth()).called(1);
      verify(() => mockRepository.getNodes()).called(1);

      await VideoRecorder.recordStep(tester, 'network', '03_refresh_complete');
    });

    testWidgets('E2E: Network Health Error State', (WidgetTester tester) async {
      when(() => mockRepository.getNetworkHealth()).thenThrow(Exception('Failed to connect to network'));
      when(() => mockRepository.getNodes()).thenAnswer((_) async => []);

      await tester.pumpWidget(createNetworkTestWidget(const NetworkHealthPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'network', '04_error_state');

      expect(find.textContaining('Failed to connect to network'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
