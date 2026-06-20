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

      expect(find.text('MÉDICO VERIFICADO'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('MÉDICO VERIFICADO'));
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

      expect(find.text('PENDIENTE DE VERIFICACIÓN'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('PENDIENTE DE VERIFICACIÓN'));
      expect(textWidget.style?.color, Colors.orangeAccent);
    });
  });
}
