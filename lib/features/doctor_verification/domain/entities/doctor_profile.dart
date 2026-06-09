import 'package:equatable/equatable.dart';

class DoctorProfile extends Equatable {
  final String id;
  final String fullName;
  final String specialty;
  final String? licenseNumber;
  final String countryCode;
  final String? institution;
  final int? yearsOfExperience;
  final List<String> languages;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorProfile({
    required this.id,
    required this.fullName,
    required this.specialty,
    this.licenseNumber,
    required this.countryCode,
    this.institution,
    this.yearsOfExperience,
    this.languages = const [],
    this.verified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        specialty,
        licenseNumber,
        countryCode,
        institution,
        yearsOfExperience,
        languages,
        verified,
        createdAt,
        updatedAt,
      ];
}
