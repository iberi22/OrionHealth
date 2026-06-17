import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/vouch.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/reputation_badge.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/doctor_profile_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/rating_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/vouch_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/services/badge_calculator.dart';

class MockDoctorProfileRepository extends Mock implements DoctorProfileRepository {}
class MockRatingRepository extends Mock implements RatingRepository {}
class MockVouchRepository extends Mock implements VouchRepository {}

void main() {
  late BadgeCalculator badgeCalculator;
  late MockDoctorProfileRepository mockProfileRepo;
  late MockRatingRepository mockRatingRepo;
  late MockVouchRepository mockVouchRepo;

  setUp(() {
    mockProfileRepo = MockDoctorProfileRepository();
    mockRatingRepo = MockRatingRepository();
    mockVouchRepo = MockVouchRepository();
    badgeCalculator = BadgeCalculator(mockProfileRepo, mockRatingRepo, mockVouchRepo);
  });

  final tDoctorId = 'doc1';
  final tDate = DateTime(2023, 1, 1);
  final tProfile = DoctorProfile(
    id: tDoctorId,
    fullName: 'Dr. Test',
    specialty: 'Testing',
    countryCode: 'US',
    verified: true,
    createdAt: tDate,
    updatedAt: tDate,
  );

  group('BadgeCalculator', () {
    test('should return null if doctor is not found or not verified', () async {
      when(() => mockProfileRepo.getDoctorProfile(tDoctorId)).thenAnswer((_) async => null);

      final result = await badgeCalculator.calculateBadge(tDoctorId);
      expect(result, isNull);

      when(() => mockProfileRepo.getDoctorProfile(tDoctorId)).thenAnswer((_) async => DoctorProfile(
        id: tDoctorId,
        fullName: 'Dr. Test',
        specialty: 'Testing',
        countryCode: 'US',
        verified: false,
        createdAt: tDate,
        updatedAt: tDate,
      ));

      final result2 = await badgeCalculator.calculateBadge(tDoctorId);
      expect(result2, isNull);
    });

    test('should return bronze for verified doctor with 3.5+ rating', () async {
      when(() => mockProfileRepo.getDoctorProfile(tDoctorId)).thenAnswer((_) async => tProfile);
      when(() => mockRatingRepo.find(tDoctorId)).thenAnswer((_) async => []);
      when(() => mockRatingRepo.getAverageForDoctor(tDoctorId)).thenAnswer((_) async => 3.6);
      when(() => mockVouchRepo.getByDoctor(tDoctorId)).thenAnswer((_) async => []);

      final result = await badgeCalculator.calculateBadge(tDoctorId);
      expect(result, BadgeLevel.bronze);
    });

    test('should return silver for 1+ vouch and 4.0+ rating (min 5 ratings)', () async {
      when(() => mockProfileRepo.getDoctorProfile(tDoctorId)).thenAnswer((_) async => tProfile);
      when(() => mockRatingRepo.find(tDoctorId)).thenAnswer((_) async => List.generate(5, (index) => DoctorRating(id: '$index', doctorId: tDoctorId, overallScore: 4, categoriesJson: '{}', createdAt: tDate, isAnonymous: false, verifiedVisit: true)));
      when(() => mockRatingRepo.getAverageForDoctor(tDoctorId)).thenAnswer((_) async => 4.2);
      when(() => mockVouchRepo.getByDoctor(tDoctorId)).thenAnswer((_) async => [Vouch(id: 'v1', vouchedBy: 'doc2', targetDoctor: tDoctorId, category: 'C', timestamp: tDate)]);

      final result = await badgeCalculator.calculateBadge(tDoctorId);
      expect(result, BadgeLevel.silver);
    });

    test('should return platinum for 5+ vouches and 4.8+ rating (min 20 ratings)', () async {
      when(() => mockProfileRepo.getDoctorProfile(tDoctorId)).thenAnswer((_) async => tProfile);
      when(() => mockRatingRepo.find(tDoctorId)).thenAnswer((_) async => List.generate(20, (index) => DoctorRating(id: '$index', doctorId: tDoctorId, overallScore: 5, categoriesJson: '{}', createdAt: tDate, isAnonymous: false, verifiedVisit: true)));
      when(() => mockRatingRepo.getAverageForDoctor(tDoctorId)).thenAnswer((_) async => 4.9);
      when(() => mockVouchRepo.getByDoctor(tDoctorId)).thenAnswer((_) async => List.generate(5, (index) => Vouch(id: 'v$index', vouchedBy: 'doc$index', targetDoctor: tDoctorId, category: 'C', timestamp: tDate)));

      final result = await badgeCalculator.calculateBadge(tDoctorId);
      expect(result, BadgeLevel.platinum);
    });
  });
}
