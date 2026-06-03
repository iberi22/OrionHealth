
import 'dart:math';
import 'package:injectable/injectable.dart';
import '../../../local_agent/domain/entities/medical_code.dart';
import '../../../local_agent/domain/repositories/medical_knowledge_repository.dart';
import '../../domain/services/clinical_reasoner_service.dart';

@LazySingleton(as: ClinicalReasonerService)
class SymphonyClinicalReasonerService implements ClinicalReasonerService {
  final MedicalKnowledgeRepository _repository;
  _SymptomIndex? _symptomIndex;
  List<Map<String, dynamic>>? _cachedMappings;

  SymphonyClinicalReasonerService(this._repository);

  void _ensureSymptomIndex(List<Map<String, dynamic>> mappings) {
    if (_symptomIndex != null && _cachedMappings == mappings) {
      return;
    }

    final invertedIndex = <String, Map<int, int>>{};
    final docLengths = <int>[];
    final tokenPattern = RegExp(r'[\wáéíóúüñ]+');

    for (int i = 0; i < mappings.length; i++) {
      final mapping = mappings[i];
      final symptom = _normalize(mapping['symptom'] as String);
      final searchTerms =
          (mapping['searchTerms'] as List<dynamic>?)?.map((e) => _normalize(e.toString())) ?? [];

      final allTermsStr = [symptom, ...searchTerms].join(' ');
      final allTokens = tokenPattern.allMatches(allTermsStr).map((m) => m.group(0)!).toList();

      final tfs = <String, int>{};
      for (final token in allTokens) {
        tfs[token] = (tfs[token] ?? 0) + 1;
      }

      for (final entry in tfs.entries) {
        invertedIndex.putIfAbsent(entry.key, () => {})[i] = entry.value;
      }
      docLengths.add(allTokens.length);
    }

    final numDocs = mappings.length;
    final idf = <String, double>{};
    for (final entry in invertedIndex.entries) {
      final df = entry.value.length;
      idf[entry.key] = log((numDocs - df + 0.5) / (df + 0.5) + 1.0);
    }

    final avgdl = docLengths.isEmpty ? 0.0 : docLengths.reduce((a, b) => a + b) / numDocs;

    _symptomIndex = _SymptomIndex(
      invertedIndex: invertedIndex,
      idf: idf,
      docLengths: docLengths,
      avgdl: avgdl,
    );
    _cachedMappings = mappings;
  }

  bool _isClose(String s1, String s2) {
    if (s1 == s2) return true;
    final lenDiff = (s1.length - s2.length).abs();
    if (lenDiff > 1) return false;
    if (s1.length < 3 || s2.length < 3) return false;
    return _levenshteinDistance(s1, s2) <= 1;
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    final List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        final int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }

      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }

  bool _isNegated(String text, int matchIndex) {
    if (matchIndex <= 0) return false;

    // Look back for negation words (up to 30 chars for performance and relevance)
    final start = matchIndex > 30 ? matchIndex - 30 : 0;
    final lookBack = text.substring(start, matchIndex).toLowerCase();

    final negationKeywords = [
      'no',
      'sin',
      'tampoco',
      'nada de',
      'ni',
      'nunca',
      'jamás',
      'negativo para',
      'ausencia de',
      'niega',
      'sin rastro de',
      'sin signos de',
      'descartado',
    ];

    for (final keyword in negationKeywords) {
      // Use word boundary to avoid matching "no" in "noche"
      // and ensure it's at the end of the lookback (optionally followed by spaces/linking words)
      final regex = RegExp('\\b$keyword\\s*([\\wáéíóúüñ]*\\s*){0,2}\$');
      if (regex.hasMatch(lookBack.trim())) {
        return true;
      }
    }

    return false;
  }

  String _normalize(String text) {
    var normalized = text.toLowerCase();
    normalized = normalized.replaceAll('á', 'a');
    normalized = normalized.replaceAll('é', 'e');
    normalized = normalized.replaceAll('í', 'i');
    normalized = normalized.replaceAll('ó', 'o');
    normalized = normalized.replaceAll('ú', 'u');
    normalized = normalized.replaceAll('ü', 'u');
    return normalized;
  }

  @override
  Future<List<DiagnosticMatch>> analyzeSymptoms(String text) async {
    final mappings = _repository.getSymptomMappings();
    if (mappings.isEmpty) return [];

    _ensureSymptomIndex(mappings);
    final index = _symptomIndex!;

    final matches = <DiagnosticMatch>[];
    final lowerText = text.toLowerCase();
    final normalizedText = _normalize(text);

    // Tokenize the input text with their start indices
    final tokens = <_SymptomToken>[];
    final matchesIter = RegExp(r'[\wáéíóúüñ]+').allMatches(normalizedText);
    for (final m in matchesIter) {
      tokens.add(_SymptomToken(m.group(0)!, m.start));
    }

    if (tokens.isEmpty) return [];

    // Candidate selection using BM25
    final queryTokens = tokens.map((t) => t.text).toSet();
    final candidateScores = <int, double>{};
    const k1 = 1.5;
    const b = 0.75;

    for (final qToken in queryTokens) {
      final matchingTokens = <String>[];
      if (index.invertedIndex.containsKey(qToken)) {
        matchingTokens.add(qToken);
      } else if (qToken.length >= 3) {
        // Fuzzy match tokens to handle typos in candidate selection
        for (final idxToken in index.invertedIndex.keys) {
          if (_isClose(qToken, idxToken)) {
            matchingTokens.add(idxToken);
          }
        }
      }

      for (final matchedToken in matchingTokens) {
        final docs = index.invertedIndex[matchedToken]!;
        final idf = index.idf[matchedToken]!;
        for (final entry in docs.entries) {
          final docIdx = entry.key;
          final tf = entry.value;

          final score = idf *
              (tf * (k1 + 1)) /
              (tf + k1 * (1 - b + b * (index.docLengths[docIdx] / index.avgdl)));
          // If multiple query tokens match the same document, we sum their BM25 scores
          candidateScores[docIdx] = (candidateScores[docIdx] ?? 0) + score;
        }
      }
    }

    // Sort candidates by BM25 score and take top N for expensive fuzzy matching
    final sortedCandidates = candidateScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Increase candidate pool to 50 for better recall while maintaining O(1) feel
    final topCandidates = sortedCandidates.take(50).map((e) => e.key).toList();

    for (final mappingIdx in topCandidates) {
      final mapping = mappings[mappingIdx];
      final symptom = _normalize(mapping['symptom'] as String);
      final searchTerms =
          (mapping['searchTerms'] as List<dynamic>?)?.map((e) => _normalize(e.toString())) ?? [];

      final allTerms = [symptom, ...searchTerms];

      double bestMatchConfidence = 0.0;
      String matchedTerm = '';
      int matchedTextIndex = -1;

      for (final term in allTerms) {
        final termTokens = term.split(RegExp(r'[\s,;.]+')).where((t) => t.isNotEmpty).toList();
        if (termTokens.isEmpty) continue;

        final n = termTokens.length;

        // Sliding window for n-gram matching
        for (int i = 0; i <= tokens.length - n; i++) {
          final windowTokens = tokens.sublist(i, i + n);
          final windowStr = windowTokens.map((t) => t.text).join(' ');

          final distance = _levenshteinDistance(windowStr, term);
          final maxLength = windowStr.length > term.length ? windowStr.length : term.length;
          final confidence = 1.0 - (distance / maxLength);

          if (confidence > bestMatchConfidence) {
            bestMatchConfidence = confidence;
            matchedTerm = term;
            matchedTextIndex = windowTokens.first.index;
          }
        }
      }

      // Threshold for fuzzy matching
      if (bestMatchConfidence > 0.75) {
        // Check for negation
        if (!_isNegated(lowerText, matchedTextIndex)) {
          final matchEntries = mapping['matches'] as List<dynamic>;
          for (final entry in matchEntries) {
            final code = entry['code'] as String;
            final baseScore = (entry['score'] as num).toDouble();
            final reason = entry['reason'] as String;

            final medCode = await _repository.searchByCode(code);
            if (medCode != null) {
              matches.add(DiagnosticMatch(
                code: medCode,
                score: baseScore * bestMatchConfidence,
                reasoning:
                    'Asociado a "$matchedTerm" (confianza ${(bestMatchConfidence * 100).toStringAsFixed(0)}%): $reason',
              ));
            }
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

class _SymptomToken {
  final String text;
  final int index;
  _SymptomToken(this.text, this.index);
}

class _SymptomIndex {
  final Map<String, Map<int, int>> invertedIndex; // token -> { docIdx -> tf }
  final Map<String, double> idf;
  final List<int> docLengths;
  final double avgdl;

  _SymptomIndex({
    required this.invertedIndex,
    required this.idf,
    required this.docLengths,
    required this.avgdl,
  });
}
