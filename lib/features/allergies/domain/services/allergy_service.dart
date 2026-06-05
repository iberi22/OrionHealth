import 'package:injectable/injectable.dart';
import '../entities/allergy.dart';
import '../../../medications/domain/entities/medication.dart';

@lazySingleton
class AllergyService {
  /// Checks for interaction between an allergy and a medication.
  /// Returns true if the medication name or notes contain the allergen name.
  bool checkInteraction(Allergy allergy, Medication medication) {
    if (!allergy.isValid) return false;

    final allergen = allergy.allergen!.toLowerCase().trim();
    final medName = medication.name.toLowerCase();
    final medNotes = medication.notes?.toLowerCase() ?? '';

    return medName.contains(allergen) || medNotes.contains(allergen);
  }

  /// Returns a numeric severity level for an allergy.
  /// 1: Mild, 2: Moderate, 3: Severe
  int getSeverityLevel(AllergySeverity severity) {
    switch (severity) {
      case AllergySeverity.mild:
        return 1;
      case AllergySeverity.moderate:
        return 2;
      case AllergySeverity.severe:
        return 3;
    }
  }
}
