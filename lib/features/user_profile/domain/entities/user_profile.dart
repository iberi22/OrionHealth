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

  /// EPS connection status
  bool isEpsConnected = false;

  /// FHIR Patient ID from EPS
  String? epsPatientId;

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
    this.onboardingCompleted = false,
    this.birthDate,
    this.sex,
    this.systolicBP,
    this.diastolicBP,
    this.heartRate,
    this.allergyName,
    this.allergySeverity,
    this.allergyNotes,
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
    this.isEpsConnected = false,
    this.epsPatientId,
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
    bool? onboardingCompleted,
    DateTime? birthDate,
    String? sex,
    int? systolicBP,
    int? diastolicBP,
    int? heartRate,
    String? allergyName,
    String? allergySeverity,
    String? allergyNotes,
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
    bool? isEpsConnected,
    String? epsPatientId,
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
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      heartRate: heartRate ?? this.heartRate,
      allergyName: allergyName ?? this.allergyName,
      allergySeverity: allergySeverity ?? this.allergySeverity,
      allergyNotes: allergyNotes ?? this.allergyNotes,
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
      isEpsConnected: isEpsConnected ?? this.isEpsConnected,
      epsPatientId: epsPatientId ?? this.epsPatientId,
      ethnicity: ethnicity ?? this.ethnicity,
    )..id = id;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, weight: $weight, height: $height, bloodType: $bloodType, uniqueId: $uniqueId, sex: $sex, systolicBP: $systolicBP, diastolicBP: $diastolicBP, heartRate: $heartRate, birthDate: $birthDate, onboardingCompleted: $onboardingCompleted)';
  }

  /// Validates the profile data
  bool validate() {
    if (age != null && (age! < 0 || age! > 150)) return false;
    if (weight != null && weight! <= 0) return false;
    if (height != null && height! <= 0) return false;
    if (systolicBP != null && (systolicBP! < 50 || systolicBP! > 250)) return false;
    if (diastolicBP != null && (diastolicBP! < 30 || diastolicBP! > 150)) return false;
    if (heartRate != null && (heartRate! < 30 || heartRate! > 220)) return false;

    if (bloodType != null) {
      const validBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      if (!validBloodTypes.contains(bloodType)) return false;
    }

    if (sex != null) {
      const validSex = ['M', 'F', 'O'];
      if (!validSex.contains(sex)) return false;
    }

    return true;
  }
}
