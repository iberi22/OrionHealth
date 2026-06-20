import '../../domain/entities/second_opinion.dart';

class SecondOpinionRequestModel extends SecondOpinionRequest {
  SecondOpinionRequestModel({
    required super.id,
    required super.patientId,
    super.primaryDoctorId,
    required super.symptoms,
    super.documents,
    required super.createdAt,
  });

  factory SecondOpinionRequestModel.fromJson(Map<String, dynamic> json) {
    return SecondOpinionRequestModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      primaryDoctorId: json['primaryDoctorId'] as String?,
      symptoms: json['symptoms'] as String,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'primaryDoctorId': primaryDoctorId,
      'symptoms': symptoms,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SecondOpinionRequestModel.fromEntity(SecondOpinionRequest entity) {
    return SecondOpinionRequestModel(
      id: entity.id,
      patientId: entity.patientId,
      primaryDoctorId: entity.primaryDoctorId,
      symptoms: entity.symptoms,
      documents: entity.documents,
      createdAt: entity.createdAt,
    );
  }
}

class SecondOpinionResponseModel extends SecondOpinionResponse {
  SecondOpinionResponseModel({
    required super.id,
    required super.requestId,
    required super.reviewerDoctorId,
    required super.recommendation,
    required super.confidence,
    required super.respondedAt,
  });

  factory SecondOpinionResponseModel.fromJson(Map<String, dynamic> json) {
    return SecondOpinionResponseModel(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      reviewerDoctorId: json['reviewerDoctorId'] as String,
      recommendation: json['recommendation'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      respondedAt: DateTime.parse(json['respondedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'reviewerDoctorId': reviewerDoctorId,
      'recommendation': recommendation,
      'confidence': confidence,
      'respondedAt': respondedAt.toIso8601String(),
    };
  }

  factory SecondOpinionResponseModel.fromEntity(SecondOpinionResponse entity) {
    return SecondOpinionResponseModel(
      id: entity.id,
      requestId: entity.requestId,
      reviewerDoctorId: entity.reviewerDoctorId,
      recommendation: entity.recommendation,
      confidence: entity.confidence,
      respondedAt: entity.respondedAt,
    );
  }
}
