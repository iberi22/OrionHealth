import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_rating.dart';

@lazySingleton
class DoctorLocalDataSource {
  final Isar _isar;
  DoctorLocalDataSource(this._isar);

  // Profile operations
  Future<List<DoctorProfile>> getAllProfiles() =>
      _isar.doctorProfiles.where().findAll();

  Future<DoctorProfile?> getProfileById(String id) =>
      _isar.doctorProfiles.filter().doctorProfileIdEqualTo(id).findFirst();

  Future<void> saveProfile(DoctorProfile p) =>
      _isar.writeTxn(() async => _isar.doctorProfiles.put(p));

  // Rating operations
  Future<List<DoctorRating>> getRatingsFor(String doctorId) =>
      _isar.doctorRatings.filter().doctorIdEqualTo(doctorId).findAll();

  Future<void> saveRating(DoctorRating r) =>
      _isar.writeTxn(() async => _isar.doctorRatings.put(r));

  Future<double> getAverageRatingFor(String doctorId) async {
    final ratings = await getRatingsFor(doctorId);
    if (ratings.isEmpty) return 0.0;
    return ratings.fold(0.0, (sum, r) => sum + r.score) / ratings.length;
  }
}
