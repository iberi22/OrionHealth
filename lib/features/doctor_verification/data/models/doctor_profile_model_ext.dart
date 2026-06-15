import 'package:equatable/equatable.dart';

/// Extended DTO for DoctorProfile with JSON serialization.
class DoctorProfileDto {
  final String? doctorProfileId;
  final String name;
  final String licenseNumber;
  final String specialty;
  final double? rating;
  final List<String> languages;
  final String? phone;
  final String? email;
  final bool verified;

  const DoctorProfileDto({
    this.doctorProfileId, required this.name, required this.licenseNumber,
    required this.specialty, this.rating, this.languages = const [],
    this.phone, this.email, this.verified = false,
  });

  Map<String, dynamic> toJson() => {
    if (doctorProfileId != null) 'doctorProfileId': doctorProfileId,
    'name': name, 'licenseNumber': licenseNumber, 'specialty': specialty,
    if (rating != null) 'rating': rating, 'languages': languages,
    if (phone != null) 'phone': phone, if (email != null) 'email': email,
    'verified': verified,
  };

  factory DoctorProfileDto.fromJson(Map<String, dynamic> j) => DoctorProfileDto(
    doctorProfileId: j['doctorProfileId'] as String?, name: j['name'] as String,
    licenseNumber: j['licenseNumber'] as String, specialty: j['specialty'] as String,
    rating: (j['rating'] as num?)?.toDouble(),
    languages: List<String>.from(j['languages'] ?? []),
    phone: j['phone'] as String?, email: j['email'] as String?,
    verified: j['verified'] as bool? ?? false,
  );
}

class DoctorRatingDto {
  final String? doctorRatingId;
  final String doctorId;
  final double score;
  final String? comment;
  final DateTime createdAt;

  const DoctorRatingDto({
    this.doctorRatingId, required this.doctorId, required this.score,
    this.comment, required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    if (doctorRatingId != null) 'doctorRatingId': doctorRatingId,
    'doctorId': doctorId, 'score': score,
    if (comment != null) 'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DoctorRatingDto.fromJson(Map<String, dynamic> j) => DoctorRatingDto(
    doctorRatingId: j['doctorRatingId'] as String?, doctorId: j['doctorId'] as String,
    score: (j['score'] as num).toDouble(), comment: j['comment'] as String?,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}
