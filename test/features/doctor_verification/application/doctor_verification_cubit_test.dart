import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/doctor_profile_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/rating_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/services/license_verifier.dart';

class MockDoctorProfileRepository extends Mock implements DoctorProfileRepository {}
class MockRatingRepository extends Mock implements RatingRepository {}
class MockLicenseVerifier extends Mock implements LicenseVerifier {}

class DoctorRatingFake extends Fake implements DoctorRating {}
class DoctorProfileFake extends Fake implements DoctorProfile {}

void main() {
  late DoctorVerificationCubit cubit;
  late MockDoctorProfileRepository mockProfileRepo;
  late MockRatingRepository mockRatingRepo;
  late MockLicenseVerifier mockLicenseVerifier;

  setUpAll(() {
    registerFallbackValue(DoctorRatingFake());
    registerFallbackValue(DoctorProfileFake());
  });

  setUp(() {
    mockProfileRepo = MockDoctorProfileRepository();
    mockRatingRepo = MockRatingRepository();
    mockLicenseVerifier = MockLicenseVerifier();
    cubit = DoctorVerificationCubit(
      mockProfileRepo,
      mockRatingRepo,
      mockLicenseVerifier,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tDate = DateTime(2023, 1, 1);
  final tDoctor = DoctorProfile(
    id: '1',
    fullName: 'Dr. Smith',
    specialty: 'Cardiology',
    licenseNumber: 'LIC-12345',
    countryCode: 'US',
    institution: 'General Hospital',
    yearsOfExperience: 10,
    languages: ['English'],
    verified: false,
    createdAt: tDate,
    updatedAt: tDate,
  );

  final tRating = DoctorRating(
    id: 'r1',
    doctorId: '1',
    overallScore: 5,
    categoriesJson: '{}',
    createdAt: tDate,
    isAnonymous: false,
    verifiedVisit: true,
  );

  group('DoctorVerificationCubit', () {
    test('initial state is DoctorVerificationInitial', () {
      expect(cubit.state, const DoctorVerificationInitial());
    });

    group('loadDoctors', () {
      test('emits [Loading, Loaded] when successful', () async {
        when(() => mockProfileRepo.getAllDoctorProfiles())
            .thenAnswer((_) async => [tDoctor]);
        when(() => mockRatingRepo.getAverageForDoctor('1'))
            .thenAnswer((_) async => 4.5);

        final expectedStates = [
          const DoctorVerificationLoading(),
          DoctorVerificationLoaded(
            doctors: [tDoctor],
            averageRatings: {'1': 4.5},
          ),
        ];

        expectLater(
          cubit.stream,
          emitsInOrder(expectedStates),
        );

        await cubit.loadDoctors();
      });

      test('emits [Loading, Error] when repository throws', () async {
        when(() => mockProfileRepo.getAllDoctorProfiles())
            .thenThrow(Exception('DB error'));

        final expectedStates = [
          const DoctorVerificationLoading(),
          const DoctorVerificationError('Error loading doctors: Exception: DB error'),
        ];

        expectLater(
          cubit.stream,
          emitsInOrder(expectedStates),
        );

        await cubit.loadDoctors();
      });

      test('loads average ratings for each doctor', () async {
        final doc2 = DoctorProfile(
          id: '2',
          fullName: 'Dr. Jones',
          specialty: 'Neurology',
          countryCode: 'US',
          createdAt: tDate,
          updatedAt: tDate,
        );

        when(() => mockProfileRepo.getAllDoctorProfiles())
            .thenAnswer((_) async => [tDoctor, doc2]);
        when(() => mockRatingRepo.getAverageForDoctor('1'))
            .thenAnswer((_) async => 4.5);
        when(() => mockRatingRepo.getAverageForDoctor('2'))
            .thenAnswer((_) async => 3.8);

        await cubit.loadDoctors();

        final state = cubit.state as DoctorVerificationLoaded;
        expect(state.averageRatings['1'], 4.5);
        expect(state.averageRatings['2'], 3.8);
      });
    });

    group('verifyDoctor', () {
      test('emits error when license number is null', () async {
        final doctorWithoutLicense = DoctorProfile(
          id: '2',
          fullName: 'Dr. No License',
          specialty: 'General',
          countryCode: 'US',
          createdAt: tDate,
          updatedAt: tDate,
          licenseNumber: null,
        );

        final expectedStates = [
          const DoctorVerificationError('License number is missing'),
        ];

        expectLater(
          cubit.stream,
          emitsInOrder(expectedStates),
        );

        await cubit.verifyDoctor(doctorWithoutLicense);
      });

      test('saves updated profile and reloads when valid', () async {
        when(() => mockLicenseVerifier.verify('LIC-12345', 'US'))
            .thenAnswer((_) async => LicenseVerificationResult.valid);
        when(() => mockProfileRepo.saveDoctorProfile(any()))
            .thenAnswer((_) async => {});
        when(() => mockProfileRepo.getAllDoctorProfiles())
            .thenAnswer((_) async => [tDoctor]);
        when(() => mockRatingRepo.getAverageForDoctor('1'))
            .thenAnswer((_) async => 4.5);

        await cubit.verifyDoctor(tDoctor);

        verify(() => mockProfileRepo.saveDoctorProfile(any())).called(1);

        final state = cubit.state;
        expect(state is LicenseVerificationResultState, isTrue);
        expect((state as LicenseVerificationResultState).result, 'valid');
      });

      test('emits license result without saving when invalid', () async {
        when(() => mockLicenseVerifier.verify('LIC-12345', 'US'))
            .thenAnswer((_) async => LicenseVerificationResult.invalid);

        final expectedStates = [
          const LicenseVerificationResultState('invalid'),
        ];

        expectLater(
          cubit.stream,
          emitsInOrder(expectedStates),
        );

        await cubit.verifyDoctor(tDoctor);

        verifyNever(() => mockProfileRepo.saveDoctorProfile(any()));
      });

      test('emits error when verification throws', () async {
        when(() => mockLicenseVerifier.verify('LIC-12345', 'US'))
            .thenThrow(Exception('Verification service down'));

        final expectedStates = [
          const DoctorVerificationError(
            'Verification failed: Exception: Verification service down',
          ),
        ];

        expectLater(
          cubit.stream,
          emitsInOrder(expectedStates),
        );

        await cubit.verifyDoctor(tDoctor);
      });
    });

    group('submitRating', () {
      test('saves rating and reloads doctors', () async {
        when(() => mockRatingRepo.save(tRating))
            .thenAnswer((_) async => {});
        when(() => mockProfileRepo.getAllDoctorProfiles())
            .thenAnswer((_) async => [tDoctor]);
        when(() => mockRatingRepo.getAverageForDoctor('1'))
            .thenAnswer((_) async => 4.5);

        await cubit.submitRating(tRating);

        verify(() => mockRatingRepo.save(tRating)).called(1);
        verify(() => mockProfileRepo.getAllDoctorProfiles()).called(1);

        final state = cubit.state;
        expect(state is DoctorVerificationLoaded, isTrue);
      });

      test('emits error when save fails', () async {
        when(() => mockRatingRepo.save(tRating))
            .thenThrow(Exception('Save failed'));

        final expectedStates = [
          const DoctorVerificationError(
            'Error submitting rating: Exception: Save failed',
          ),
        ];

        expectLater(
          cubit.stream,
          emitsInOrder(expectedStates),
        );

        await cubit.submitRating(tRating);
      });
    });
  });
}
