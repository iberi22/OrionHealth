import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/widgets/contribution_card.dart';

void main() {
  final contribution = Contribution(
    id: '1',
    userId: 'user1',
    type: ContributionType.storage,
    rewardPoints: 50,
    timestamp: DateTime(2025, 1, 1, 10, 30),
  );

  testWidgets('ContributionCard renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContributionCard(contribution: contribution),
        ),
      ),
    );

    expect(find.text('Almacenamiento'), findsOneWidget);
    expect(find.text('+50'), findsOneWidget);
    expect(find.byIcon(Icons.storage), findsOneWidget);
  });
}
