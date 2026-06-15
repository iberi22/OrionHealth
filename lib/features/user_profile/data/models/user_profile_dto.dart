import '../../domain/entities/user_profile.dart';

class UserProfileDto {
  final String? name;
  final DateTime? birthDate;
  final String? sex;
  final double? weight;
  final double? height;
  final List<String> medicalConditions;
  final List<String> currentMedications;
  final bool onboardingCompleted;
  final bool isEpsConnected;
  final String? epsPatientId;
  final String? allergyName;
  final bool? familyHistoryCvd;
  final bool? familyHistoryDiabetes;

  const UserProfileDto({
    this.name, this.birthDate, this.sex, this.weight, this.height,
    this.medicalConditions = const [], this.currentMedications = const [],
    this.onboardingCompleted = false, this.isEpsConnected = false,
    this.epsPatientId, this.allergyName, this.familyHistoryCvd, this.familyHistoryDiabetes,
  });

  factory UserProfileDto.fromEntity(UserProfile e) => UserProfileDto(
    name: e.name, birthDate: e.birthDate, sex: e.sex,
    weight: e.weight, height: e.height,
    medicalConditions: e.medicalConditions,
    currentMedications: e.currentMedications,
    onboardingCompleted: e.onboardingCompleted,
    isEpsConnected: e.isEpsConnected,
    epsPatientId: e.epsPatientId,
    allergyName: e.allergyName,
    familyHistoryCvd: e.familyHistoryCvd,
    familyHistoryDiabetes: e.familyHistoryDiabetes,
  );

  UserProfile toEntity() => UserProfile(
    name: name, birthDate: birthDate, sex: sex,
    weight: weight, height: height,
    medicalConditions: medicalConditions,
    currentMedications: currentMedications,
    onboardingCompleted: onboardingCompleted,
    isEpsConnected: isEpsConnected,
    epsPatientId: epsPatientId,
    allergyName: allergyName,
    familyHistoryCvd: familyHistoryCvd,
    familyHistoryDiabetes: familyHistoryDiabetes,
  );

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
    if (sex != null) 'sex': sex,
    if (weight != null) 'weight': weight,
    if (height != null) 'height': height,
    'medicalConditions': medicalConditions,
    'currentMedications': currentMedications,
    'onboardingCompleted': onboardingCompleted,
    'isEpsConnected': isEpsConnected,
    if (epsPatientId != null) 'epsPatientId': epsPatientId,
    if (allergyName != null) 'allergyName': allergyName,
    if (familyHistoryCvd != null) 'familyHistoryCvd': familyHistoryCvd,
    if (familyHistoryDiabetes != null) 'familyHistoryDiabetes': familyHistoryDiabetes,
  };

  factory UserProfileDto.fromJson(Map<String, dynamic> j) => UserProfileDto(
    name: j['name'] as String?,
    birthDate: j['birthDate'] != null ? DateTime.parse(j['birthDate'] as String) : null,
    sex: j['sex'] as String?,
    weight: (j['weight'] as num?)?.toDouble(),
    height: (j['height'] as num?)?.toDouble(),
    medicalConditions: List<String>.from(j['medicalConditions'] ?? []),
    currentMedications: List<String>.from(j['currentMedications'] ?? []),
    onboardingCompleted: j['onboardingCompleted'] as bool? ?? false,
    isEpsConnected: j['isEpsConnected'] as bool? ?? false,
    epsPatientId: j['epsPatientId'] as String?,
    allergyName: j['allergyName'] as String?,
    familyHistoryCvd: j['familyHistoryCvd'] as bool?,
    familyHistoryDiabetes: j['familyHistoryDiabetes'] as bool?,
  );
}
