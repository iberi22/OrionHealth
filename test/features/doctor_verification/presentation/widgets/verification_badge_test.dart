import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/verification_badge.dart';

void main() {
  group('VerificationBadge', () {
    testWidgets('renders verified status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: true),
          ),
        ),
      );

      expect(find.text('Verificado'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Verificado'));
      expect(textWidget.style?.color, Colors.greenAccent);
    });

    testWidgets('renders unverified status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: false),
          ),
        ),
      );

      expect(find.text('Sin verificar'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Sin verificar'));
      expect(textWidget.style?.color, Colors.orangeAccent);
    });
  });
}
