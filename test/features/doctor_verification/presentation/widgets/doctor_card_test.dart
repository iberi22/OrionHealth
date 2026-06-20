import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/doctor_card.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/verification_badge.dart';

void main() {
  final tDoctor = DoctorProfile(
    id: '1',
    fullName: 'Dr. Smith',
    specialty: 'Cardiology',
    countryCode: 'US',
    verified: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('DoctorCard', () {
    testWidgets('renders doctor information correctly', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoctorCard(
              doctor: tDoctor,
              rating: 4.5,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Dr. Smith'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.byType(VerificationBadge), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);

      await tester.tap(find.byType(DoctorCard));
      expect(tapped, isTrue);
    });
  });
}
