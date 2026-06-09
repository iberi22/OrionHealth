import '../../domain/entities/doctor_profile.dart';

class DoctorProfileModel extends DoctorProfile {
  DoctorProfileModel({
    required super.id,
    required super.fullName,
    required super.specialty,
    super.licenseNumber,
    required super.countryCode,
    super.institution,
    super.yearsOfExperience,
    super.languages,
    super.verified,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      specialty: json['specialty'] as String,
      licenseNumber: json['licenseNumber'] as String?,
      countryCode: json['countryCode'] as String,
      institution: json['institution'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      verified: json['verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'countryCode': countryCode,
      'institution': institution,
      'yearsOfExperience': yearsOfExperience,
      'languages': languages,
      'verified': verified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DoctorProfileModel.fromEntity(DoctorProfile entity) {
    return DoctorProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      specialty: entity.specialty,
      licenseNumber: entity.licenseNumber,
      countryCode: entity.countryCode,
      institution: entity.institution,
      yearsOfExperience: entity.yearsOfExperience,
      languages: entity.languages,
      verified: entity.verified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
