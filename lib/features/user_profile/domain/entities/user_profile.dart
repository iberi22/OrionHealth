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

  String? avatarUrl; // Profile picture URL

  String? uniqueId; // User ID like "ORION-XXX"

  String? email;

  String? phoneNumber;

  UserProfile({
    this.name,
    this.age,
    this.weight,
    this.height,
    this.bloodType,
    this.avatarUrl,
    this.uniqueId,
    this.email,
    this.phoneNumber,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    double? weight,
    double? height,
    String? bloodType,
    String? avatarUrl,
    String? uniqueId,
    String? email,
    String? phoneNumber,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodType: bloodType ?? this.bloodType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      uniqueId: uniqueId ?? this.uniqueId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    )..id = this.id;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, weight: $weight, height: $height, bloodType: $bloodType, uniqueId: $uniqueId)';
  }
}
