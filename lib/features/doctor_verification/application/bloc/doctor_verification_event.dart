part of 'doctor_verification_bloc.dart';

abstract class DoctorVerificationEvent extends Equatable {
  const DoctorVerificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadDoctors extends DoctorVerificationEvent {
  const LoadDoctors();
}

class VerifyDoctor extends DoctorVerificationEvent {
  final DoctorProfile doctor;
  const VerifyDoctor(this.doctor);

  @override
  List<Object?> get props => [doctor];
}

class SubmitRating extends DoctorVerificationEvent {
  final DoctorRating rating;
  const SubmitRating(this.rating);

  @override
  List<Object?> get props => [rating];
}
