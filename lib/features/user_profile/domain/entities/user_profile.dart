import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  String? name;

  int? age;

  double? weight; // in kg

  double? height; // in cm

  String? bloodType;

  bool onboardingCompleted = false;

  DateTime? birthDate;

  String? sex;

  int? systolicBP;

  int? diastolicBP;

  int? heartRate;

  String? allergyName;

  String? allergySeverity;

  String? allergyNotes;

  String? llmProvider;

  String? localModelName;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, weight: $weight, height: $height, bloodType: $bloodType, onboardingCompleted: $onboardingCompleted, birthDate: $birthDate, sex: $sex, systolicBP: $systolicBP, diastolicBP: $diastolicBP, heartRate: $heartRate, allergyName: $allergyName, allergySeverity: $allergySeverity, allergyNotes: $allergyNotes)';
  }
}
