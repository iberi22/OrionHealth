// TODO: migrate from data/ — moved to infrastructure/repositories/isar_rating_repository.dart
// This file is kept temporarily. Remove after verifying new imports work.

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/doctor_rating.dart';
import '../../domain/repositories/rating_repository.dart';

@LazySingleton(as: RatingRepository)
class IsarRatingRepository implements RatingRepository {
  final Isar _isar;

  IsarRatingRepository(this._isar);

  @override
  Future<void> save(DoctorRating rating) async {
    await _isar.writeTxn(() async {
      await _isar.doctorRatings.put(rating);
    });
  }

  @override
  Future<List<DoctorRating>> find(String doctorId) async {
    return await _isar.doctorRatings.filter().doctorIdEqualTo(doctorId).findAll();
  }

  @override
  Future<double> getAverageForDoctor(String doctorId) async {
    final ratings = await find(doctorId);
    if (ratings.isEmpty) return 0.0;

    final total = ratings.fold(0, (sum, rating) => sum + rating.overallScore);
    return total / ratings.length;
  }
}
