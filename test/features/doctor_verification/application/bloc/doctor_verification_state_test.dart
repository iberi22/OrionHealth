import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/application/bloc/doctor_verification_bloc.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';

void main() {
  final tDate = DateTime(2023, 1, 1);
  final tDoctor = DoctorProfile(
    id: '1',
    fullName: 'Dr. Test',
    specialty: 'Cardiology',
    countryCode: 'US',
    createdAt: tDate,
    updatedAt: tDate,
  );

  group('DoctorVerificationState', () {
    group('DoctorVerificationInitial', () {
      test('supports value equality', () {
        expect(
          const DoctorVerificationInitial(),
          equals(const DoctorVerificationInitial()),
        );
      });
    });

    group('DoctorVerificationLoading', () {
      test('supports value equality', () {
        expect(
          const DoctorVerificationLoading(),
          equals(const DoctorVerificationLoading()),
        );
      });
    });

    group('DoctorVerificationLoaded', () {
      test('supports value equality', () {
        expect(
          const DoctorVerificationLoaded(doctors: [], averageRatings: {}),
          equals(const DoctorVerificationLoaded(doctors: [], averageRatings: {})),
        );
      });
    });

    group('DoctorVerificationError', () {
      test('supports value equality', () {
        expect(
          const DoctorVerificationError('err'),
          equals(const DoctorVerificationError('err')),
        );
      });
    });

    group('LicenseVerificationResultState', () {
      test('supports value equality', () {
        expect(
          const LicenseVerificationResultState('valid'),
          equals(const LicenseVerificationResultState('valid')),
        );
      });
    });
  });
}
