import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/verification_status.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/verification_card.dart';

void main() {
  final tDoctor = DoctorProfile(
    id: 'DOC-123',
    fullName: 'Dr. Gregory House',
    specialty: 'Diagnostic Medicine',
    countryCode: 'US',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('VerificationCard Widget Tests', () {
    testWidgets('should render doctor data correctly (name, specialty, id)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationCard(
              doctor: tDoctor,
              status: VerificationStatus.pending,
            ),
          ),
        ),
      );

      expect(find.text('Dr. Gregory House'), findsOneWidget);
      expect(find.text('Diagnostic Medicine'), findsOneWidget);
      expect(find.text('ID: DOC-123'), findsOneWidget);
    });

    testWidgets('should call onVerify when button is pressed in pending state', (WidgetTester tester) async {
      bool verifyCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationCard(
              doctor: tDoctor,
              status: VerificationStatus.pending,
              onVerify: () => verifyCalled = true,
            ),
          ),
        ),
      );

      final verifyButton = find.byKey(const Key('verify_button'));
      expect(verifyButton, findsOneWidget);
      expect(find.text('VERIFICAR AHORA'), findsOneWidget);

      await tester.tap(verifyButton);
      expect(verifyCalled, isTrue);
    });

    testWidgets('should show PENDIENTE status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationCard(
              doctor: tDoctor,
              status: VerificationStatus.pending,
            ),
          ),
        ),
      );

      expect(find.text('PENDIENTE DE VERIFICACIÓN'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    });

    testWidgets('should show VERIFICADO status and hide button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationCard(
              doctor: tDoctor,
              status: VerificationStatus.verified,
            ),
          ),
        ),
      );

      expect(find.text('MÉDICO VERIFICADO'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Perfil verificado correctamente'), findsOneWidget);
      expect(find.byKey(const Key('verify_button')), findsNothing);
    });

    testWidgets('should show RECHAZADO status and retry button', (WidgetTester tester) async {
      bool verifyCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerificationCard(
              doctor: tDoctor,
              status: VerificationStatus.rejected,
              onVerify: () => verifyCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('VERIFICACIÓN RECHAZADA'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final verifyButton = find.byKey(const Key('verify_button'));
      expect(verifyButton, findsOneWidget);
      expect(find.text('REINTENTAR VERIFICACIÓN'), findsOneWidget);

      await tester.tap(verifyButton);
      expect(verifyCalled, isTrue);
    });
  });
}
