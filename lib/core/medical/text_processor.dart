// Copyright 2024 OrionHealth
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Ported from OpenMed (Apache 2.0)
// Original source: https://github.com/maziyarpanahi/openmed/blob/master/openmed/processing/text.py

/// Handles text preprocessing and cleaning for medical text analysis.
class TextProcessor {
  final bool lowercase;
  final bool removePunctuation;
  final bool removeNumbers;
  final bool normalizeWhitespace;

  /// Medical abbreviations that should be preserved.
  static final Set<String> medicalAbbreviations = {
    'mg', 'ml', 'kg', 'lb', 'oz', 'cm', 'mm', 'hr', 'min',
    'BP', 'RR', 'temp', 'O2', 'CO2', 'HIV', 'AIDS',
    'ICU', 'ER', 'OR', 'CBC', 'EKG', 'ECG', 'MRI', 'CT',
    'X-ray', 'ultrasound', 'BMI', 'COPD', 'CHF', 'MI',
    'stroke', 'TIA', 'DVT', 'PE', 'UTI', 'Dr',
  };

  TextProcessor({
    this.lowercase = false,
    this.removePunctuation = false,
    this.removeNumbers = false,
    this.normalizeWhitespace = true,
  });

  /// Clean and preprocess text.
  String cleanText(String text) {
    String processed = text;

    // Normalize whitespace initially
    if (normalizeWhitespace) {
      processed = processed.trim().replaceAll(RegExp(r'\s+'), ' ');
    }

    // Handle medical abbreviations before other processing
    final protectedAbbrevs = <String, String>{};
    int i = 0;

    // Sort abbreviations by length descending to match longer ones first
    final sortedAbbrevs = medicalAbbreviations.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    // We protect abbreviations to preserve them during punctuation/number removal
    for (final abbrev in sortedAbbrevs) {
      final placeholder = '__ABBREV_${i}__';
      // Match whole words only
      final regex = RegExp('\\b${RegExp.escape(abbrev)}\\b', caseSensitive: false);

      if (regex.hasMatch(processed)) {
        processed = processed.replaceAllMapped(regex, (match) {
          protectedAbbrevs[placeholder] = match.group(0)!;
          return placeholder;
        });
        i++;
      }
    }

    // Remove or clean numbers
    if (removeNumbers) {
      // Preserve placeholders (__ABBREV_N__) and medical measurements (e.g., "120/80", "98.6°F")
      // Only remove numbers that are not part of a placeholder or measurement
      processed = processed.replaceAllMapped(RegExp(r'(?<![./\d])\d+(?![./\d°%])'), (match) {
          // Check if this number is part of a __ABBREV_ placeholder
          final sub = processed.substring(match.start, processed.length);
          if (sub.startsWith('__ABBREV_')) return match.group(0)!;
          // Check if preceded by __ABBREV_ (i.e., __ABBREV_123)
          final prefix = processed.substring(0, match.start);
          if (prefix.endsWith('__ABBREV_')) return match.group(0)!;
          return ' ';
      });
    }

    // Remove punctuation
    if (removePunctuation) {
      // Keep hyphens in compound medical terms
      processed = processed.replaceAll(RegExp(r'[^\w\s\-]'), ' ');
    }

    // Convert to lowercase
    if (lowercase) {
      processed = processed.toLowerCase();
    }

    // Restore protected abbreviations
    protectedAbbrevs.forEach((placeholder, original) {
      final restored = lowercase ? original.toLowerCase() : original;
      // Use case-insensitive replace: text may have been lowercased
      processed = processed.replaceAll(RegExp(RegExp.escape(placeholder), caseSensitive: false), restored);
    });

    // Final whitespace normalization
    if (normalizeWhitespace) {
      processed = processed.trim().replaceAll(RegExp(r'\s+'), ' ');
    }

    return processed;
  }

  /// Segment text into sentences using medical text-aware rules.
  List<String> segmentSentences(String text) {
    if (text.isEmpty) return [];

    // Temporarily protect medical abbreviations followed by a dot
    final abbrevWithDot = medicalAbbreviations.map((e) => '$e.').toList();
    // Sort by length descending
    abbrevWithDot.sort((a, b) => b.length.compareTo(a.length));

    String textModified = text;
    final protectedDots = <String, String>{};
    int i = 0;

    for (final abbrev in abbrevWithDot) {
        // Note: no \\b prefix because some abbrevs follow digits (e.g. "50mg.")
        final regex = RegExp(RegExp.escape(abbrev), caseSensitive: false);
        if (regex.hasMatch(textModified)) {
            final placeholder = '__DOT_${i}__';
            textModified = textModified.replaceAllMapped(regex, (match) {
                protectedDots[placeholder] = match.group(0)!;
                return placeholder;
            });
            i++;
        }
    }

    // Simple sentence segmentation: split by .!? followed by whitespace OR end of string
    final segments = <String>[];
    int start = 0;
    // Punctuation followed by space or end of string.
    final splitRegex = RegExp(r'[.!?]+(?=\s+|$)', dotAll: true);
    final allMatches = splitRegex.allMatches(textModified).toList();

    for (final match in allMatches) {
        segments.add(textModified.substring(start, match.end));
        start = match.end;
    }
    if (start < textModified.length) {
        segments.add(textModified.substring(start));
    }

    List<String> sentences = [];
    for (var s in segments) {
      // Restore dots
      String restored = s;
      protectedDots.forEach((placeholder, original) {
          restored = restored.replaceAll(placeholder, original);
      });
      restored = restored.trim();
      if (restored.isNotEmpty) {
        sentences.add(restored);
      }
    }

    // If no matches (no punctuation at all), return the whole text as one sentence
    if (sentences.isEmpty && text.trim().isNotEmpty) {
      return [text.trim()];
    }

    return sentences;
  }

  /// Extract medication dosages from text.
  List<String> extractDosages(String text) {
    final dosagePatterns = [
      RegExp(r'\b\d+(?:\.\d+)?\s*(?:mg|ml|g|kg|mcg|units?)\b', caseSensitive: false),
      RegExp(r'\b\d+\s*x\s*/\s*day\b', caseSensitive: false),
    ];

    final Set<String> results = {};
    for (final pattern in dosagePatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        results.add(match.group(0)!);
      }
    }
    return results.toList();
  }

  /// Extract vital signs from text.
  List<String> extractVitalSigns(String text) {
    final vitalPatterns = [
      RegExp(r'\b(?:bp|blood pressure):?\s*\d+/\d+\b', caseSensitive: false),
      RegExp(r'\b(?:hr|heart rate):?\s*\d+\b', caseSensitive: false),
      RegExp(r'\b(?:temp|temperature):?\s*\d+\.?\d*\s*[°]?[fFcC]?\b', caseSensitive: false),
      RegExp(r'\b(?:rr|respiratory rate):?\s*\d+\b', caseSensitive: false),
      RegExp(r'\b(?:o2|spo2|oxygen saturation):?\s*\d+%(?:\s+|$|[.,])', caseSensitive: false),
    ];

    final Set<String> results = {};
    for (final pattern in vitalPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        results.add(match.group(0)!);
      }
    }
    return results.toList();
  }

  /// Postprocess text: capitalize first letter and trim.
  static String postprocessText(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}
