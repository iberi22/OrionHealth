import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_rating.dart';
import '../../domain/repositories/doctor_profile_repository.dart';
import '../../domain/repositories/rating_repository.dart';
import '../../domain/services/license_verifier.dart';

part 'doctor_verification_event.dart';
part 'doctor_verification_state.dart';

@injectable
class DoctorVerificationBloc extends Bloc<DoctorVerificationEvent, DoctorVerificationState> {
  final DoctorProfileRepository _profileRepository;
  final RatingRepository _ratingRepository;
  final LicenseVerifier _licenseVerifier;

  DoctorVerificationBloc(
    this._profileRepository,
    this._ratingRepository,
    this._licenseVerifier,
  ) : super(const DoctorVerificationInitial()) {
    on<LoadDoctors>(_onLoadDoctors);
    on<VerifyDoctor>(_onVerifyDoctor);
    on<SubmitRating>(_onSubmitRating);
  }

  Future<void> _onLoadDoctors(LoadDoctors event, Emitter<DoctorVerificationState> emit) async {
    emit(const DoctorVerificationLoading());
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

  Future<void> _onVerifyDoctor(VerifyDoctor event, Emitter<DoctorVerificationState> emit) async {
    final doctor = event.doctor;
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

        // Internal logic to reload without adding event to avoid state interleaving in tests if possible,
        // but Emitter is for current event.
        // Actually, the recommended way in Bloc is to emit states from the current handler.

        final doctors = await _profileRepository.getAllDoctorProfiles();
        final Map<String, double> averageRatings = {};
        for (final doc in doctors) {
          averageRatings[doc.id] = await _ratingRepository.getAverageForDoctor(doc.id);
        }

        emit(DoctorVerificationLoaded(
          doctors: doctors,
          averageRatings: averageRatings,
        ));
      }

      emit(LicenseVerificationResultState(result.name));
    } catch (e) {
      emit(DoctorVerificationError('Verification failed: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitRating(SubmitRating event, Emitter<DoctorVerificationState> emit) async {
    try {
      await _ratingRepository.save(event.rating);

      final doctors = await _profileRepository.getAllDoctorProfiles();
      final Map<String, double> averageRatings = {};
      for (final doc in doctors) {
        averageRatings[doc.id] = await _ratingRepository.getAverageForDoctor(doc.id);
      }

      emit(DoctorVerificationLoaded(
        doctors: doctors,
        averageRatings: averageRatings,
      ));
    } catch (e) {
      emit(DoctorVerificationError('Error submitting rating: ${e.toString()}'));
    }
  }
}
