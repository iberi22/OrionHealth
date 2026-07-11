import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/presentation/widgets/connection_status_badge.dart';
import 'package:orionhealth_health/core/utils/connectivity_manager.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('ConnectionStatusBadge Golden Tests', () {
    testWidgets('ConnectionStatusBadge - online', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        const ConnectionStatusBadge(
          initialStatus: ConnectivityStatus.connected,
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(ConnectionStatusBadge),
        matchesGoldenFile('goldens/connection_status_badge_online.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ConnectionStatusBadge - offline', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        const ConnectionStatusBadge(
          initialStatus: ConnectivityStatus.disconnected,
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(ConnectionStatusBadge),
        matchesGoldenFile('goldens/connection_status_badge_offline.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ConnectionStatusBadge - unknown', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        const ConnectionStatusBadge(
          initialStatus: ConnectivityStatus.unknown,
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(ConnectionStatusBadge),
        matchesGoldenFile('goldens/connection_status_badge_unknown.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
