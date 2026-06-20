import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/application/bloc/doctor_verification_bloc.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';

void main() {
  group('DoctorVerificationEvent', () {
    group('LoadDoctors', () {
      test('supports value equality', () {
        expect(const LoadDoctors(), equals(const LoadDoctors()));
      });
    });

    group('VerifyDoctor', () {
      final doctor = DoctorProfile(
        id: '1',
        fullName: 'Dr. Test',
        specialty: 'Cardiology',
        countryCode: 'US',
        createdAt: DateTime(2023),
        updatedAt: DateTime(2023),
      );

      test('supports value equality', () {
        expect(VerifyDoctor(doctor), equals(VerifyDoctor(doctor)));
      });
    });

    group('SubmitRating', () {
      final rating = DoctorRating(
        id: 'r1',
        doctorId: '1',
        overallScore: 5,
        categoriesJson: '{}',
        createdAt: DateTime(2023),
        isAnonymous: false,
        verifiedVisit: true,
      );

      test('supports value equality', () {
        expect(SubmitRating(rating), equals(SubmitRating(rating)));
      });
    });
  });
}
