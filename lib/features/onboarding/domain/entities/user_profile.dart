import 'package:equatable/equatable.dart';

/// User profile entity for onboarding (plain Dart model, NOT Isar collection)
class UserProfile extends Equatable {
  final int id;

  final String? name;
  final DateTime? birthDate;
  final String? sex; // M, F, O
  final double? weightKg;
  final double? heightCm;
  final List<String> conditions;
  final List<String> familyHistory;
  final List<String> medications;
  final List<String> allergies;
  final bool privacyConsent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int onboardingStep;
  final bool onboardingCompleted;
  final String? locale;

  const UserProfile({
    this.id = 0,
    this.name,
    this.birthDate,
    this.sex,
    this.weightKg,
    this.heightCm,
    this.conditions = const [],
    this.familyHistory = const [],
    this.medications = const [],
    this.allergies = const [],
    this.privacyConsent = false,
    required this.createdAt,
    required this.updatedAt,
    this.onboardingStep = 0,
    this.onboardingCompleted = false,
    this.locale,
  });

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  UserProfile copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    String? sex,
    double? weightKg,
    double? heightCm,
    List<String>? conditions,
    List<String>? familyHistory,
    List<String>? medications,
    List<String>? allergies,
    bool? privacyConsent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? onboardingStep,
    bool? onboardingCompleted,
    String? locale,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      conditions: conditions ?? this.conditions,
      familyHistory: familyHistory ?? this.familyHistory,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      privacyConsent: privacyConsent ?? this.privacyConsent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate?.toIso8601String(),
        'sex': sex,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'conditions': conditions,
        'familyHistory': familyHistory,
        'medications': medications,
        'allergies': allergies,
        'privacyConsent': privacyConsent,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'onboardingStep': onboardingStep,
        'onboardingCompleted': onboardingCompleted,
        'locale': locale,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? 0,
        name: json['name'],
        birthDate: json['birthDate'] != null
            ? DateTime.parse(json['birthDate'])
            : null,
        sex: json['sex'],
        weightKg: json['weightKg']?.toDouble(),
        heightCm: json['heightCm']?.toDouble(),
        conditions: List<String>.from(json['conditions'] ?? []),
        familyHistory: List<String>.from(json['familyHistory'] ?? []),
        medications: List<String>.from(json['medications'] ?? []),
        allergies: List<String>.from(json['allergies'] ?? []),
        privacyConsent: json['privacyConsent'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        onboardingStep: json['onboardingStep'] ?? 0,
        onboardingCompleted: json['onboardingCompleted'] ?? false,
        locale: json['locale'],
      );

  @override
  List<Object?> get props => [
        id,
        name,
        birthDate,
        sex,
        weightKg,
        heightCm,
        conditions,
        familyHistory,
        medications,
        allergies,
        privacyConsent,
        createdAt,
        updatedAt,
        onboardingStep,
        onboardingCompleted,
        locale,
      ];
}
