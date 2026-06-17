import 'package:equatable/equatable.dart';
import '../domain/entities/doctor_profile.dart';

abstract class DoctorVerificationState extends Equatable {
  const DoctorVerificationState();

  @override
  List<Object?> get props => [];
}

class DoctorVerificationInitial extends DoctorVerificationState {}

class DoctorVerificationLoading extends DoctorVerificationState {}

class DoctorVerificationLoaded extends DoctorVerificationState {
  final List<DoctorProfile> doctors;
  final Map<String, double> averageRatings;

  const DoctorVerificationLoaded({
    required this.doctors,
    required this.averageRatings,
  });

  @override
  List<Object?> get props => [doctors, averageRatings];
}

class DoctorVerificationError extends DoctorVerificationState {
  final String message;

  const DoctorVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class LicenseVerificationResultState extends DoctorVerificationState {
  final String result; // e.g., 'valid', 'invalid', 'unknown'

  const LicenseVerificationResultState(this.result);

  @override
  List<Object?> get props => [result];
}
