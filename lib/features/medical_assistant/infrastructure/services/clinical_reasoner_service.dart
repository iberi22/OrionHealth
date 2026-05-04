
import 'package:injectable/injectable.dart';
import '../../../local_agent/domain/entities/medical_code.dart';
import '../../../local_agent/domain/repositories/medical_knowledge_repository.dart';
import '../../domain/services/clinical_reasoner_service.dart';

@LazySingleton(as: ClinicalReasonerService)
class SymphonyClinicalReasonerService implements ClinicalReasonerService {
  final MedicalKnowledgeRepository _repository;

  SymphonyClinicalReasonerService(this._repository);

  @override
  Future<List<DiagnosticMatch>> analyzeSymptoms(String text) async {
    final matches = <DiagnosticMatch>[];
    final mappings = _repository.getSymptomMappings();
    final lowerText = text.toLowerCase();

    for (final mapping in mappings) {
      final symptom = (mapping['symptom'] as String).toLowerCase();
      final searchTerms = (mapping['searchTerms'] as List<dynamic>?)?.map((e) => e.toString().toLowerCase()) ?? [];

      bool found = lowerText.contains(symptom);
      if (!found) {
        for (final term in searchTerms) {
          if (lowerText.contains(term)) {
            found = true;
            break;
          }
        }
      }

      if (found) {
        final matchEntries = mapping['matches'] as List<dynamic>;
        for (final entry in matchEntries) {
          final code = entry['code'] as String;
          final score = (entry['score'] as num).toDouble();
          final reason = entry['reason'] as String;

          final medCode = await _repository.searchByCode(code);
          if (medCode != null) {
            matches.add(DiagnosticMatch(
              code: medCode,
              score: score,
              reasoning: 'Asociado a "$symptom": $reason',
            ));
          }
        }
      }
    }

    // Deduplicate and sort by score
    final uniqueMatches = <String, DiagnosticMatch>{};
    for (final m in matches) {
      if (!uniqueMatches.containsKey(m.code.code) || uniqueMatches[m.code.code]!.score < m.score) {
        uniqueMatches[m.code.code] = m;
      }
    }

    final result = uniqueMatches.values.whereType<DiagnosticMatch>().toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> analyzeMedications(List<String> drugNamesOrCodes) async {
    // 1. Identify codes for names
    final codes = <String>[];
    for (final input in drugNamesOrCodes) {
      final results = await _repository.searchByTermInStandard(input, 'RxNorm');
      if (results.isNotEmpty) {
        codes.add(results.first.code);
      } else if (input.contains(RegExp(r'^\d+$'))) {
        codes.add(input);
      }
    }

    // 2. Check interactions
    return await _repository.checkInteractions(codes);
  }

  @override
  String synthesizeHolisticSummary(List<MedicalCode> codes) {
    final buffer = StringBuffer();
    
    final List<String> physicalImpacts = [];
    for (final c in codes) {
      if (c.category == 'Mental' && c.physicalHealthImpact != null) {
        physicalImpacts.add('• ${c.displayName}: ${c.physicalHealthImpact}');
      }
    }

    final List<String> mentalImpacts = [];
    for (final c in codes) {
      if (c.category != 'Mental' && c.mentalHealthImpact != null) {
        mentalImpacts.add('• ${c.displayName}: ${c.mentalHealthImpact}');
      }
    }

    if (mentalImpacts.isNotEmpty) {
      buffer.writeln('\n### 🧠 Impacto en Salud Mental');
      buffer.writeln(mentalImpacts.join('\n'));
    }

    if (physicalImpacts.isNotEmpty) {
      buffer.writeln('\n### 🏃 Manifestaciones Físicas');
      buffer.writeln(physicalImpacts.join('\n'));
    }

    return buffer.toString();
  }
}
