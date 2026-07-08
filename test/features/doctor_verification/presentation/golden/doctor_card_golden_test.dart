import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/doctor_card.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  final mockDoctor = DoctorProfile(
    id: 'doc-123',
    fullName: 'Dr. Jane Smith',
    specialty: 'Cardiologist',
    licenseNumber: 'MD12345',
    countryCode: 'US',
    institution: 'City Hospital',
    yearsOfExperience: 10,
    languages: ['English', 'Spanish'],
    verified: true,
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );

  testWidgets('DoctorCard golden test - verified', (tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(
      wrapWithMaterial(
        Scaffold(
          body: Center(
            child: DoctorCard(
              doctor: mockDoctor,
              rating: 4.8,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(DoctorCard),
      matchesGoldenFile('goldens/doctor_card_verified.png'),
    );

    resetGoldenTest(tester);
  });

  testWidgets('DoctorCard golden test - unverified', (tester) async {
    setupGoldenTest(tester);

    final unverifiedDoctor = DoctorProfile(
      id: 'doc-456',
      fullName: 'Dr. John Doe',
      specialty: 'Pediatrician',
      licenseNumber: 'MD67890',
      countryCode: 'US',
      verified: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    await tester.pumpWidget(
      wrapWithMaterial(
        Scaffold(
          body: Center(
            child: DoctorCard(
              doctor: unverifiedDoctor,
              rating: 3.5,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(DoctorCard),
      matchesGoldenFile('goldens/doctor_card_unverified.png'),
    );

    resetGoldenTest(tester);
  });
}
