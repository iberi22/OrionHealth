import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/doctor_profile.dart';
import '../domain/entities/doctor_rating.dart';
import '../domain/repositories/doctor_profile_repository.dart';
import '../domain/repositories/rating_repository.dart';
import '../domain/services/license_verifier.dart';
import 'doctor_verification_state.dart';

@injectable
class DoctorVerificationCubit extends Cubit<DoctorVerificationState> {
  final DoctorProfileRepository _profileRepository;
  final RatingRepository _ratingRepository;
  final LicenseVerifier _licenseVerifier;

  DoctorVerificationCubit(
    this._profileRepository,
    this._ratingRepository,
    this._licenseVerifier,
  ) : super(DoctorVerificationInitial());

  Future<void> loadDoctors() async {
    emit(DoctorVerificationLoading());
    try {
      final doctors = await _profileRepository.getAllDoctorProfiles();
      final Map<String, double> averageRatings = {};

      for (final doctor in doctors) {
        averageRatings[doctor.id] = await _ratingRepository.getAverageForDoctor(doctor.id);
      }

      emit(DoctorVerificationLoaded(
        doctors: doctors,
        averageRatings: averageRatings,
      ));
    } catch (e) {
      emit(DoctorVerificationError('Error loading doctors: ${e.toString()}'));
    }
  }

  Future<void> verifyDoctor(DoctorProfile doctor) async {
    if (doctor.licenseNumber == null) {
      emit(const DoctorVerificationError('License number is missing'));
      return;
    }

    try {
      final result = await _licenseVerifier.verify(
        doctor.licenseNumber!,
        doctor.countryCode,
      );

      if (result == LicenseVerificationResult.valid) {
        final updatedDoctor = DoctorProfile(
          id: doctor.id,
          fullName: doctor.fullName,
          specialty: doctor.specialty,
          licenseNumber: doctor.licenseNumber,
          countryCode: doctor.countryCode,
          institution: doctor.institution,
          yearsOfExperience: doctor.yearsOfExperience,
          languages: doctor.languages,
          verified: true,
          createdAt: doctor.createdAt,
          updatedAt: DateTime.now(),
        );
        updatedDoctor.isarId = doctor.isarId;

        await _profileRepository.saveDoctorProfile(updatedDoctor);
        await loadDoctors();
      }

      emit(LicenseVerificationResultState(result.name));
    } catch (e) {
      emit(DoctorVerificationError('Verification failed: ${e.toString()}'));
    }
  }

  Future<void> submitRating(DoctorRating rating) async {
    try {
      await _ratingRepository.save(rating);
      await loadDoctors();
    } catch (e) {
      emit(DoctorVerificationError('Error submitting rating: ${e.toString()}'));
    }
  }
}
