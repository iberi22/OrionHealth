import 'package:injectable/injectable.dart';

import 'medical_text_normalizer_config.dart';

/// Service that normalizes medical text queries before embedding generation.
///
/// Performs lowercasing, expands medical abbreviations according to
/// [MedicalTextNormalizationConfig], removes stop words, and normalizes whitespace.
@injectable
class MedicalTextNormalizer {
  final MedicalTextNormalizationConfig config;

  MedicalTextNormalizer({this.config = const MedicalTextNormalizationConfig()});

  /// Normalizes the input medical text.
  ///
  /// Process:
  /// 1. Trims initial whitespace and handles empty strings.
  /// 2. Filters out standalone stop words defined in [config].
  /// 3. Expands medical abbreviations matching keys in [config.abbreviations].
  /// 4. Converts to lowercase and normalizes remaining whitespace.
  String normalize(String text) {
    if (text.trim().isEmpty) return '';

    String result = text.trim();

    // 1. Remove stop words before abbreviation expansion
    // so expanded phrases (e.g., 'índice de masa corporal') remain intact.
    if (config.stopWords.isNotEmpty) {
      for (final stopWord in config.stopWords) {
        final pattern = RegExp(
          r'\b' + RegExp.escape(stopWord) + r'\b',
          caseSensitive: false,
        );
        result = result.replaceAll(pattern, '');
      }
    }

    // 2. Expand abbreviations (sorted by length descending to match longer abbreviations first)
    final sortedKeys = config.abbreviations.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final abbr in sortedKeys) {
      final expansion = config.abbreviations[abbr]!;
      final pattern = RegExp(
        r'\b' + RegExp.escape(abbr) + r'\b',
        caseSensitive: false,
      );
      result = result.replaceAll(pattern, expansion);
    }

    // 3. Lowercase and collapse consecutive spaces
    return result.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
