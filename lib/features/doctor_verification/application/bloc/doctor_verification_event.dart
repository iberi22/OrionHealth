import 'package:equatable/equatable.dart';
import '../../domain/entities/doctor_profile.dart';
import '../../domain/entities/doctor_rating.dart';

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