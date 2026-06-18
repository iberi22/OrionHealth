import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
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

      test('props are empty', () {
        expect(const DoctorVerificationInitial().props, equals([]));
      });
    });

    group('DoctorVerificationLoading', () {
      test('supports value equality', () {
        expect(
          const DoctorVerificationLoading(),
          equals(const DoctorVerificationLoading()),
        );
      });

      test('props are empty', () {
        expect(const DoctorVerificationLoading().props, equals([]));
      });
    });

    group('DoctorVerificationLoaded', () {
      test('supports value equality', () {
        const state1 = DoctorVerificationLoaded(
          doctors: [],
          averageRatings: {},
        );
        const state2 = DoctorVerificationLoaded(
          doctors: [],
          averageRatings: {},
        );

        expect(state1, equals(state2));
      });

      test('props contain doctors and averageRatings', () {
        const state = DoctorVerificationLoaded(
          doctors: [],
          averageRatings: {},
        );

        expect(state.props, containsAll([[], {}]));
      });

      test('distinct doctors produce different objects', () {
        final state1 = DoctorVerificationLoaded(
          doctors: [tDoctor],
          averageRatings: {'1': 4.5},
        );
        final state2 = DoctorVerificationLoaded(
          doctors: [],
          averageRatings: {},
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('DoctorVerificationError', () {
      test('supports value equality', () {
        const error1 = DoctorVerificationError('Error loading doctors');
        const error2 = DoctorVerificationError('Error loading doctors');

        expect(error1, equals(error2));
      });

      test('props contain message', () {
        const error = DoctorVerificationError('Test error');

        expect(error.props, contains('Test error'));
      });

      test('different messages produce different objects', () {
        const error1 = DoctorVerificationError('Error 1');
        const error2 = DoctorVerificationError('Error 2');

        expect(error1, isNot(equals(error2)));
      });
    });

    group('LicenseVerificationResultState', () {
      test('supports value equality', () {
        const state1 = LicenseVerificationResultState('valid');
        const state2 = LicenseVerificationResultState('valid');

        expect(state1, equals(state2));
      });

      test('props contain result', () {
        const state = LicenseVerificationResultState('valid');

        expect(state.props, contains('valid'));
      });

      test('different results produce different objects', () {
        const state1 = LicenseVerificationResultState('valid');
        const state2 = LicenseVerificationResultState('invalid');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('State type hierarchy', () {
      test('all states extend DoctorVerificationState', () {
        expect(const DoctorVerificationInitial(), isA<DoctorVerificationState>());
        expect(const DoctorVerificationLoading(), isA<DoctorVerificationState>());
        expect(const DoctorVerificationLoaded(doctors: [], averageRatings: {}), isA<DoctorVerificationState>());
        expect(const DoctorVerificationError('err'), isA<DoctorVerificationState>());
        expect(const LicenseVerificationResultState('valid'), isA<DoctorVerificationState>());
      });
    });
  });
}
