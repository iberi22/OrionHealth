import 'dart:math';
import 'package:health_contract/health_contract.dart' as contract;
import 'package:injectable/injectable.dart';
import '../../../allergies/domain/repositories/allergy_repository.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import 'ecosystem_import_service.dart';

class DietaryProfileExportDraft {
  final Map<String, dynamic> record;

  /// Must be reviewed: omission does not mean the user has no restrictions.
  final List<String> unmappedAllergens;
  const DietaryProfileExportDraft(this.record, this.unmappedAllergens);
}

@lazySingleton
class DietaryProfileExportService {
  final AllergyRepository _allergies;
  final UserProfileRepository _profiles;
  final EcosystemSubjectStore _subjects;
  DietaryProfileExportService(this._allergies, this._profiles, this._subjects);

  /// Bind identity only after the reviewed export has explicit consent.
  Future<void> confirm(
    DietaryProfileExportDraft draft, {
    required bool consent,
  }) async {
    if (!consent) {
      throw const FormatException('Export requires explicit consent.');
    }
    contract.Envelope.fromJson(draft.record);
    final data = draft.record['data'] as Map<String, dynamic>;
    if (!parseEcosystemTimestamp(
      data['expiresAt'] as String,
    ).isAfter(DateTime.now())) {
      throw const FormatException('Dietary profile has expired.');
    }
    await _subjects.bind(draft.record['subject'] as String);
  }

  Future<DietaryProfileExportDraft> build({
    required String gosDataset,
    required DateTime expiresAt,
  }) async {
    final now = DateTime.now().toUtc();
    if (!expiresAt.isAfter(now)) {
      throw const FormatException('Choose a future expiry.');
    }
    final allergies = await _allergies.getAllergies();
    final profile = await _profiles.getUserProfile();
    final allergens = <String>{};
    final unmapped = <String>[];
    for (final allergy in allergies) {
      final name = allergy.allergen?.trim();
      if (name == null || name.isEmpty) continue;
      final canonical = canonicalAllergen(name);
      if (canonical == null) {
        unmapped.add(name);
      } else {
        allergens.add(canonical);
      }
    }
    // Legacy onboarding stores one allergy on the user profile.
    final legacy = profile?.allergyName?.trim();
    if (legacy != null && legacy.isNotEmpty) {
      final canonical = canonicalAllergen(legacy);
      if (canonical == null) {
        if (!unmapped.contains(legacy)) unmapped.add(legacy);
      } else {
        allergens.add(canonical);
      }
    }
    final targets = <String, dynamic>{
      if (profile?.dietaryGoalsKcalPerDay != null)
        'kcalPerDay': profile!.dietaryGoalsKcalPerDay,
      if (profile?.dietaryGoalsProteinGPerDay != null)
        'proteinGPerDay': profile!.dietaryGoalsProteinGPerDay,
    };
    final subject = await _subjects.read() ?? 'subj_${newEcosystemUlid(now)}';
    final record = <String, dynamic>{
      'schema': 'swal.health/v1/dietary-profile',
      'id': newEcosystemUlid(now),
      'subject': subject,
      'createdAt': now.toIso8601String(),
      'source': {'app': 'orionhealth', 'version': '0.10.1'},
      'gosDataset': gosDataset,
      'data': {
        'allergens': allergens.toList()..sort(),
        'diets': (profile?.dietaryPreferences ?? <String>[]).toSet().toList()
          ..sort(),
        'targets': targets,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
      },
    };
    contract.Envelope.fromJson(record);
    return DietaryProfileExportDraft(record, List.unmodifiable(unmapped));
  }
}

/// Explicit labels only. Does not infer restrictions from notes or conditions.
String? canonicalAllergen(String label) {
  final normalized = label.trim().toLowerCase();
  const groups = {
    'celery': ['celery', 'apio'],
    'crustacean': ['crustacean', 'crustaceans', 'crustaceos', 'crustáceos'],
    'egg': ['egg', 'eggs', 'huevo', 'huevos'],
    'fish': ['fish', 'pescado'],
    'gluten': ['gluten'],
    'lupin': ['lupin', 'altramuz', 'altramuces'],
    'milk': ['milk', 'leche'],
    'mollusc': ['mollusc', 'molluscs', 'moluscos'],
    'mustard': ['mustard', 'mostaza'],
    'peanut': ['peanut', 'peanuts', 'mani', 'maní', 'cacahuete', 'cacahuetes'],
    'sesame': ['sesame', 'sesamo', 'sésamo'],
    'soy': ['soy', 'soya', 'soja'],
    'sulphite': ['sulphite', 'sulphites', 'sulfito', 'sulfitos'],
    'tree-nut': [
      'tree-nut',
      'tree nuts',
      'frutos de cáscara',
      'frutos de cascara',
    ],
  };
  for (final entry in groups.entries) {
    if (normalized == 'gos:allergen/${entry.key}' ||
        entry.value.contains(normalized)) {
      return 'gos:allergen/${entry.key}';
    }
  }
  return null;
}

String newEcosystemUlid(DateTime now) {
  const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  var timestamp = now.millisecondsSinceEpoch;
  final chars = List<String>.filled(26, '0');
  for (var i = 9; i >= 0; i--) {
    chars[i] = alphabet[timestamp & 31];
    timestamp >>= 5;
  }
  final random = Random.secure();
  for (var i = 10; i < 26; i++) {
    chars[i] = alphabet[random.nextInt(32)];
  }
  return chars.join();
}
