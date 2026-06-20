import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/bloc/doctor_verification_bloc.dart';
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
  late DoctorVerificationBloc bloc;
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
    bloc = DoctorVerificationBloc(
      mockProfileRepo,
      mockRatingRepo,
      mockLicenseVerifier,
    );
  });

  tearDown(() {
    bloc.close();
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
    languages: const ['English'],
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

  group('DoctorVerificationBloc', () {
    test('initial state is DoctorVerificationInitial', () {
      expect(bloc.state, const DoctorVerificationInitial());
    });

    test('emits [Loading, Loaded] when LoadDoctors is successful', () async {
      when(() => mockProfileRepo.getAllDoctorProfiles())
          .thenAnswer((_) async => [tDoctor]);
      when(() => mockRatingRepo.getAverageForDoctor('1'))
          .thenAnswer((_) async => 4.5);

      final expected = [
        const DoctorVerificationLoading(),
        DoctorVerificationLoaded(
          doctors: [tDoctor],
          averageRatings: {'1': 4.5},
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const LoadDoctors());
    });

    test('emits [Loading, Error] when LoadDoctors fails', () async {
      when(() => mockProfileRepo.getAllDoctorProfiles())
          .thenThrow(Exception('DB error'));

      final expected = [
        const DoctorVerificationLoading(),
        const DoctorVerificationError('Error loading doctors: Exception: DB error'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const LoadDoctors());
    });

    test('emits [Loading, ResultState, Loading, Loaded] when VerifyDoctor is valid', () async {
      when(() => mockLicenseVerifier.verify('LIC-12345', 'US'))
          .thenAnswer((_) async => LicenseVerificationResult.valid);
      when(() => mockProfileRepo.saveDoctorProfile(any()))
          .thenAnswer((_) async => {});
      when(() => mockProfileRepo.getAllDoctorProfiles())
          .thenAnswer((_) async => [tDoctor]);
      when(() => mockRatingRepo.getAverageForDoctor('1'))
          .thenAnswer((_) async => 4.5);

      expectLater(bloc.stream, emitsInOrder([
        const DoctorVerificationLoading(),
        const LicenseVerificationResultState('valid'),
        const DoctorVerificationLoading(),
        DoctorVerificationLoaded(
          doctors: [tDoctor],
          averageRatings: {'1': 4.5},
        ),
      ]));

      bloc.add(VerifyDoctor(tDoctor));
    });

    test('emits [Loading, Loaded] when SubmitRating is successful', () async {
      when(() => mockRatingRepo.save(any()))
          .thenAnswer((_) async => {});
      when(() => mockProfileRepo.getAllDoctorProfiles())
          .thenAnswer((_) async => [tDoctor]);
      when(() => mockRatingRepo.getAverageForDoctor('1'))
          .thenAnswer((_) async => 4.5);

      final expected = [
        const DoctorVerificationLoading(),
        DoctorVerificationLoaded(
          doctors: [tDoctor],
          averageRatings: {'1': 4.5},
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(SubmitRating(tRating));
    });
  });
}
