import 'package:injectable/injectable.dart';
import '../entities/reputation_badge.dart';
import '../repositories/doctor_profile_repository.dart';
import '../repositories/rating_repository.dart';
import '../repositories/vouch_repository.dart';

@lazySingleton
class BadgeCalculator {
  final DoctorProfileRepository _profileRepository;
  final RatingRepository _ratingRepository;
  final VouchRepository _vouchRepository;

  BadgeCalculator(
    this._profileRepository,
    this._ratingRepository,
    this._vouchRepository,
  );

  Future<BadgeLevel?> calculateBadge(String doctorId) async {
    final profile = await _profileRepository.getDoctorProfile(doctorId);
    if (profile == null || !profile.verified) return null;

    final ratings = await _ratingRepository.find(doctorId);
    final avgRating = await _ratingRepository.getAverageForDoctor(doctorId);
    final vouches = await _vouchRepository.getByDoctor(doctorId);

    final totalVerifiedLicenses = 1; // Base verified profile
    final vouchCount = vouches.length;
    final ratingCount = ratings.length;

    // Criteria:
    // Platinum: 5+ vouches, 4.8+ avg rating (min 20 ratings), verified licenses
    // Gold: 3+ vouches, 4.5+ avg rating (min 10 ratings)
    // Silver: 1+ vouch, 4.0+ avg rating (min 5 ratings)
    // Bronze: Verified + 3.5+ avg rating

    if (vouchCount >= 5 && avgRating >= 4.8 && ratingCount >= 20) {
      return BadgeLevel.platinum;
    } else if (vouchCount >= 3 && avgRating >= 4.5 && ratingCount >= 10) {
      return BadgeLevel.gold;
    } else if (vouchCount >= 1 && avgRating >= 4.0 && ratingCount >= 5) {
      return BadgeLevel.silver;
    } else if (avgRating >= 3.5) {
      return BadgeLevel.bronze;
    }

    return null;
  }
}
