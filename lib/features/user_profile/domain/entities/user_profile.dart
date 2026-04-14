import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  String? name;

  DateTime? birthDate;

  String? sex; // 'Male', 'Female', 'Other'

  double? weight; // in kg

  double? height; // in cm

  String? bloodType;

  bool isOnboardingComplete = false;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, birthDate: $birthDate, sex: $sex, weight: $weight, height: $height, bloodType: $bloodType, isOnboardingComplete: $isOnboardingComplete)';
  }
}
