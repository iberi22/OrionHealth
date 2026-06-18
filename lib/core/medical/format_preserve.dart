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
// Original source: https://github.com/maziyarpanahi/openmed/blob/master/openmed/core/anonymizer/format_preserve.py

/// Format-preserving helpers for surrogate generation.
///
/// When we replace a phone number, date, email, or ID with a fake surrogate,
/// this module ensures the surrogate *looks like* the original — same digit
/// groupings, same separators, same overall shape. That keeps deidentified
/// text useful for downstream tooling (regex matchers, length-sensitive UIs,
/// PDF templates).
library;


import 'dart:math';

/// Returns the lengths of each contiguous digit run in [text].
///
/// ```dart
/// extractDigitGroups('+1 (415) 555-1234') // [1, 3, 3, 4]
/// extractDigitGroups('+33 6 12 34 56 78') // [2, 1, 2, 2, 2, 2]
/// ```
List<int> extractDigitGroups(String text) {
  final re = RegExp(r'\d+');
  return re.allMatches(text).map((m) => m.group(0)!.length).toList();
}

/// Generate a fake phone number that mirrors [original]'s structure.
///
/// Non-digit characters (`+`, spaces, dashes, parentheses) are kept in place;
/// each digit run is filled with new random digits.
String preservePhoneFormat(String original, {Random? rng}) {
  final r = rng ?? Random();
  return original.split('').map((ch) {
    if (ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39) {
      return String.fromCharCode(0x30 + r.nextInt(10));
    }
    return ch;
  }).join();
}

const _dateSeparators = ['/', '-', '.', ' '];

/// Generate a fake date that uses the same separator and ordering as
/// [original].
///
/// [dayFirst] controls fallback when the original is ambiguous
/// (e.g. `05/06/2020`). Returns a surrogate date in the same format,
/// drawn uniformly from the last 100 years.
String preserveDateFormat(String original, {bool dayFirst = false, Random? rng}) {
  final r = rng ?? Random();

  final days = r.nextInt(365 * 100);
  final fake = DateTime(1925, 1, 1).add(Duration(days: days));

  // Detect separator
  String sep = '/';
  for (final c in _dateSeparators) {
    if (original.contains(c)) {
      sep = c;
      break;
    }
  }

  // Detect ordering: yyyy-first if a 4-digit run is at the start
  if (RegExp(r'^\d{4}').hasMatch(original)) {
    return '${fake.year.toString().padLeft(4, '0')}$sep'
        '${fake.month.toString().padLeft(2, '0')}$sep'
        '${fake.day.toString().padLeft(2, '0')}';
  }
  if (dayFirst) {
    return '${fake.day.toString().padLeft(2, '0')}$sep'
        '${fake.month.toString().padLeft(2, '0')}$sep'
        '${fake.year.toString().padLeft(4, '0')}';
  }
  return '${fake.month.toString().padLeft(2, '0')}$sep'
      '${fake.day.toString().padLeft(2, '0')}$sep'
      '${fake.year.toString().padLeft(4, '0')}';
}

/// Use [fakeEmail]'s local part with [original]'s domain.
///
/// Keeps the domain stable (often a meaningful tenant marker like
/// `@hospital.org`) while randomizing the local part. Falls back to
/// [fakeEmail] verbatim if either side doesn't parse as `local@domain`.
String preserveEmailPattern(String original, String fakeEmail) {
  if (!original.contains('@') || !fakeEmail.contains('@')) return fakeEmail;
  final fakeLocal = fakeEmail.split('@')[0];
  final originalDomain = original.split('@')[1];
  return '$fakeLocal@$originalDomain';
}

/// Replace digits in [original] with random digits, keeping all other
/// characters in place.
///
/// Use for opaque IDs where format matters but no checksum applies (MRN,
/// account numbers, sometimes ZIP codes).
String preserveIdPattern(String original, {Random? rng}) {
  final r = rng ?? Random();

  const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lower = 'abcdefghijklmnopqrstuvwxyz';

  return original.split('').map((ch) {
    final code = ch.codeUnitAt(0);
    if (code >= 0x30 && code <= 0x39) {
      return String.fromCharCode(0x30 + r.nextInt(10));
    }
    if (code >= 0x41 && code <= 0x5a) {
      return upper[r.nextInt(upper.length)];
    }
    if (code >= 0x61 && code <= 0x7a) {
      return lower[r.nextInt(lower.length)];
    }
    return ch;
  }).join();
}
