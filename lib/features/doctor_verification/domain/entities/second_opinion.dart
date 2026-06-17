import 'package:isar/isar.dart';

part 'second_opinion.g.dart';

@collection
class SecondOpinionRequest {
  Id isarId = Isar.autoIncrement;

  final String id;
  final String patientId;
  final String? primaryDoctorId;
  final String symptoms;
  final List<String> documents; // URLs or paths
  final DateTime createdAt;

  SecondOpinionRequest({
    required this.id,
    required this.patientId,
    this.primaryDoctorId,
    required this.symptoms,
    this.documents = const [],
    required this.createdAt,
  });
}

@collection
class SecondOpinionResponse {
  Id isarId = Isar.autoIncrement;

  final String id;
  final String requestId;
  final String reviewerDoctorId;
  final String recommendation;
  final double confidence; // 0.0 to 1.0
  final DateTime respondedAt;

  SecondOpinionResponse({
    required this.id,
    required this.requestId,
    required this.reviewerDoctorId,
    required this.recommendation,
    required this.confidence,
    required this.respondedAt,
  });
}
