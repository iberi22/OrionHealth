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

  @Enumerated(EnumType.name)
  String? llmProvider; // LlmProvider enum as string

  String? localModelName;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, weight: $weight, height: $height, bloodType: $bloodType)';
  }
}
