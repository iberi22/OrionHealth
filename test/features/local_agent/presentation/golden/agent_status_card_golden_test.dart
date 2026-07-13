import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/agent_status.dart';
import 'package:orionhealth_health/features/local_agent/presentation/widgets/agent_status_card.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('AgentStatusCard Golden Tests', () {
    testWidgets('AgentStatusCard - Online', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        const Scaffold(
          body: AgentStatusCard(
            agentName: 'Orion Assistant',
            status: AgentStatus.online,
          ),
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(AgentStatusCard),
        matchesGoldenFile('goldens/agent_status_card_online.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AgentStatusCard - Offline', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        const Scaffold(
          body: AgentStatusCard(
            agentName: 'Orion Assistant',
            status: AgentStatus.offline,
          ),
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(AgentStatusCard),
        matchesGoldenFile('goldens/agent_status_card_offline.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AgentStatusCard - Busy', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        const Scaffold(
          body: AgentStatusCard(
            agentName: 'Orion Assistant',
            status: AgentStatus.busy,
          ),
        ),
      ));
      await tester.pump();

      await expectLater(
        find.byType(AgentStatusCard),
        matchesGoldenFile('goldens/agent_status_card_busy.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
