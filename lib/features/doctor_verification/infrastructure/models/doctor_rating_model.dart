import 'dart:convert';
import '../../domain/entities/doctor_rating.dart';

class DoctorRatingModel extends DoctorRating {
  DoctorRatingModel({
    required super.id,
    required super.doctorId,
    super.patientId,
    required super.overallScore,
    required super.categoriesJson,
    super.comment,
    required super.createdAt,
    required super.isAnonymous,
    required super.verifiedVisit,
  });

  factory DoctorRatingModel.fromJson(Map<String, dynamic> json) {
    return DoctorRatingModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      patientId: json['patientId'] as String?,
      overallScore: json['overallScore'] as int,
      categoriesJson: json['categoriesJson'] is Map
          ? jsonEncode(json['categoriesJson'])
          : json['categoriesJson'] as String,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      verifiedVisit: json['verifiedVisit'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'overallScore': overallScore,
      'categoriesJson': categoriesJson,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'isAnonymous': isAnonymous,
      'verifiedVisit': verifiedVisit,
    };
  }

  factory DoctorRatingModel.fromEntity(DoctorRating entity) {
    return DoctorRatingModel(
      id: entity.id,
      doctorId: entity.doctorId,
      patientId: entity.patientId,
      overallScore: entity.overallScore,
      categoriesJson: entity.categoriesJson,
      comment: entity.comment,
      createdAt: entity.createdAt,
      isAnonymous: entity.isAnonymous,
      verifiedVisit: entity.verifiedVisit,
    );
  }
}
