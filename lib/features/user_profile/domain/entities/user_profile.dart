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

  bool allowCloudApi;

  String? llmProvider;

  String? localModelName;

  /// Medical conditions (ICD-10 codes, comma-separated)
  final List<String> medicalConditions;

  /// Current medications (RxNorm codes, comma-separated)
  final List<String> currentMedications;

  /// Smoking status
  String? smokingStatus; // never, former, current

  /// Family history of cardiovascular disease
  bool? familyHistoryCvd;

  /// Family history of diabetes
  bool? familyHistoryDiabetes;

  /// History of hypertension
  bool? hasHypertension;

  /// History of cardiovascular disease
  bool? hasCardiovascularDisease;

  /// History of steroid use
  bool? hasSteroidUse;

  /// Ethnicity for risk calculations
  String? ethnicity;

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
    this.allowCloudApi = true,
    this.llmProvider,
    this.localModelName,
    this.medicalConditions = const [],
    this.currentMedications = const [],
    this.smokingStatus,
    this.familyHistoryCvd,
    this.familyHistoryDiabetes,
    this.hasHypertension,
    this.hasCardiovascularDisease,
    this.hasSteroidUse,
    this.ethnicity,
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
    bool? allowCloudApi,
    String? llmProvider,
    String? localModelName,
    List<String>? medicalConditions,
    List<String>? currentMedications,
    String? smokingStatus,
    bool? familyHistoryCvd,
    bool? familyHistoryDiabetes,
    bool? hasHypertension,
    bool? hasCardiovascularDisease,
    bool? hasSteroidUse,
    String? ethnicity,
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
      allowCloudApi: allowCloudApi ?? this.allowCloudApi,
      llmProvider: llmProvider ?? this.llmProvider,
      localModelName: localModelName ?? this.localModelName,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      familyHistoryCvd: familyHistoryCvd ?? this.familyHistoryCvd,
      familyHistoryDiabetes: familyHistoryDiabetes ?? this.familyHistoryDiabetes,
      hasHypertension: hasHypertension ?? this.hasHypertension,
      hasCardiovascularDisease: hasCardiovascularDisease ?? this.hasCardiovascularDisease,
      hasSteroidUse: hasSteroidUse ?? this.hasSteroidUse,
      ethnicity: ethnicity ?? this.ethnicity,
    )..id = id;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, weight: $weight, height: $height, bloodType: $bloodType, uniqueId: $uniqueId)';
  }
}
