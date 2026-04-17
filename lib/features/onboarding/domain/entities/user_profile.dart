class OnboardingUserProfile {
  String name;
  DateTime? birthDate;
  String? sex;
  double? weightKg;
  double? heightCm;
  List<String> conditions;
  List<String> familyHistory;
  List<String> medications;
  List<String> allergies;
  String locale;

  OnboardingUserProfile({
    this.name = '',
    this.birthDate,
    this.sex,
    this.weightKg,
    this.heightCm,
    this.conditions = const [],
    this.familyHistory = const [],
    this.medications = const [],
    this.allergies = const [],
    this.locale = 'es',
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

  bool get isComplete => name.isNotEmpty;
}
