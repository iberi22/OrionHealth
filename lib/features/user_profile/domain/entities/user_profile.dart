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

  double? totalRamGb;

  String? deviceProfile; // Light, Medium, High-end

  String? recommendedModel; // 2B, 7B, 9B, cloud-only

  String? gpuCapability;

  String? deviceAbi;

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
    this.totalRamGb,
    this.deviceProfile,
    this.recommendedModel,
    this.gpuCapability,
    this.deviceAbi,
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
    double? totalRamGb,
    String? deviceProfile,
    String? recommendedModel,
    String? gpuCapability,
    String? deviceAbi,
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
      totalRamGb: totalRamGb ?? this.totalRamGb,
      deviceProfile: deviceProfile ?? this.deviceProfile,
      recommendedModel: recommendedModel ?? this.recommendedModel,
      gpuCapability: gpuCapability ?? this.gpuCapability,
      deviceAbi: deviceAbi ?? this.deviceAbi,
    )..id = this.id;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, weight: $weight, height: $height, bloodType: $bloodType, uniqueId: $uniqueId)';
  }
}
