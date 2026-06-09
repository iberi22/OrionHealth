import 'package:isar/isar.dart';

part 'doctor_profile.g.dart';

@collection
class DoctorProfile {
  Id isarId = Isar.autoIncrement;

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

  DoctorProfile({
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          specialty == other.specialty &&
          licenseNumber == other.licenseNumber &&
          countryCode == other.countryCode &&
          institution == other.institution &&
          yearsOfExperience == other.yearsOfExperience &&
          _listEquals(languages, other.languages) &&
          verified == other.verified &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      specialty.hashCode ^
      licenseNumber.hashCode ^
      countryCode.hashCode ^
      institution.hashCode ^
      yearsOfExperience.hashCode ^
      languages.hashCode ^
      verified.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
