import 'dart:convert';
import 'package:isar/isar.dart';

part 'doctor_rating.g.dart';

@collection
class DoctorRating {
  Id isarId = Isar.autoIncrement;

  final String id;
  final String doctorId;
  final String? patientId;
  final int overallScore;

  final String categoriesJson;

  @ignore
  Map<String, int> get categories => jsonDecode(categoriesJson).cast<String, int>();

  final String? comment;
  final DateTime createdAt;
  final bool isAnonymous;
  final bool verifiedVisit;

  DoctorRating({
    required this.id,
    required this.doctorId,
    this.patientId,
    required this.overallScore,
    required this.categoriesJson,
    this.comment,
    required this.createdAt,
    required this.isAnonymous,
    required this.verifiedVisit,
  });

  bool validate() {
    if (overallScore < 1 || overallScore > 5) return false;
    if (comment != null && comment!.length > 500) return false;
    return true;
  }
}
