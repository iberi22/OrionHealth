import '../entities/doctor_rating.dart';

abstract class RatingRepository {
  Future<void> save(DoctorRating rating);
  Future<List<DoctorRating>> find(String doctorId);
  Future<double> getAverageForDoctor(String doctorId);
}
