class DoctorRating {
  final String id;
  final String doctorId;
  final String? patientId;
  final int overallScore;
  final Map<String, int> categories;
  final String? comment;
  final DateTime createdAt;
  final bool isAnonymous;
  final bool verifiedVisit;

  DoctorRating({
    required this.id,
    required this.doctorId,
    this.patientId,
    required this.overallScore,
    required this.categories,
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
