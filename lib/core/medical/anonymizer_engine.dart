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
// Original source: https://github.com/maziyarpanahi/openmed/blob/master/openmed/core/anonymizer/engine.py
//                    https://github.com/maziyarpanahi/openmed/blob/master/openmed/core/anonymizer/registry.py

/// Surrogate-based PII/PHI anonymization engine.
///
/// Generates realistic fake values for detected PII entities using a
/// locale-aware set of generators. Supports:
///
///   - **Format preservation**: phone digit groups, date separators, email
///     domains, and ID shapes are kept stable.
///   - **Deterministic mode**: identical `(label, originalValue)` pairs
///     produce the same surrogate within a session via seeded RNG.
///   - **Customizable**: add or override label generators via
///     [AnonymizerEngine.registerGenerator].
///
/// Does NOT use Faker (no external dependency). Generates structurally
/// realistic surrogates using format-preserving replacement and built-in
/// generators.
library;


import 'dart:math';

import 'format_preserve.dart';

/// Signature for a label-to-surrogate generator.
///
/// Takes the [original] text and an optional [Random] instance for
/// reproducibility.
typedef SurrogateGenerator = String Function(String original, Random rng);

/// Maps each canonical PII label to a surrogate generator.
///
/// Unless overridden, every label uses a format-preserving replacement
/// (digits only → random digits; mixed → random digits + alpha).
class AnonymizerEngine {
  final Map<String, SurrogateGenerator> _generators = {};
  final Random _rng;
  final bool _consistent;

  /// Create an engine.
  ///
  /// If [consistent] is true, the same `(label, originalValue)` always maps
  /// to the same surrogate within this engine's lifetime (by hashing the pair
  /// into the RNG seed for each call).
  ///
  /// [seed] provides cross-session determinism when [consistent] is also true.
  AnonymizerEngine({bool consistent = false, int? seed})
      : _rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch),
        _consistent = consistent {
    _registerDefaults();
  }

  /// Build a deterministic seed for `(label, original)`.
  int _deriveSeed(String label, String original) {
    var h = 17;
    for (var i = 0; i < label.length; i++) {
      h = h * 31 + label.codeUnitAt(i);
    }
    for (var i = 0; i < original.length; i++) {
      h = h * 31 + original.codeUnitAt(i);
    }
    return h & 0x7FFFFFFFFFFFFFFF; // keep non-negative
  }

  /// Register a custom generator for [label].
  void registerGenerator(String label, SurrogateGenerator generator) {
    _generators[label] = generator;
  }

  /// Generate a surrogate for [original] of type [label].
  ///
  /// Uses format-preserving replacement by default; specific labels (email,
  /// phone, ssn, creditCard) get dedicated generators when registered.
  ///
  /// If [_consistent] is true, the RNG is seeded from `(label, original)`
  /// so repeated calls return the same surrogate.
  String surrogate(String original, String label) {
    Random rng;
    if (_consistent) {
      rng = Random(_deriveSeed(label, original));
    } else {
      rng = _rng;
    }

    final generator = _generators[label];
    if (generator != null) {
      return generator(original, rng);
    }

    // Default: format-preserve whatever shape the original has
    if (original.contains('@')) {
      // email-like: replace local part, keep domain
      return _genEmail(original, rng);
    }
    if (RegExp(r'\d').hasMatch(original)) {
      return preserveIdPattern(original, rng: rng);
    }
    // pure alpha — replace each char
    return _randomString(original.length, rng);
  }

  // ------------------------------------------------------------------
  // Built-in generators (registered in constructor)
  // ------------------------------------------------------------------

  String _genPhone(String original, Random rng) {
    if (RegExp(r'\d').hasMatch(original)) {
      return preservePhoneFormat(original, rng: rng);
    }
    return _randomDigits(10, rng);
  }

  String _genEmail(String original, Random rng) {
    if (!original.contains('@')) {
      return '${_randomString(8, rng)}@example.com';
    }
    final domain = original.split('@')[1];
    return '${_randomString(8, rng)}@$domain';
  }

  String _genSsn(String original, Random rng) {
    // Last 4 visible, rest random
    final digits = original.replaceAll(RegExp(r'[^0-9]'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '';
    // Generate 3 random area + 2 random group
    final area = (rng.nextInt(899) + 100).toString(); // 100-999
    final group = rng.nextInt(100).toString().padLeft(2, '0');
    return '$area-$group-$last4';
  }

  String _genCreditCard(String original, Random rng) {
    // Last 4 visible, rest random
    final digits = original.replaceAll(RegExp(r'[^0-9]'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '';
    // Generate random prefix + middle digits
    final prefix = (rng.nextInt(8999) + 1000).toString();
    final middle = rng.nextInt(100000000).toString().padLeft(8, '0');
    return '$prefix-$middle-$last4';
  }

  String _genName(String original, Random rng) {
    const firstNames = [
      'Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey',
      'Riley', 'Avery', 'Quinn', 'Harper', 'Sage',
    ];
    const lastNames = [
      'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
      'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    ];
    final fn = firstNames[rng.nextInt(firstNames.length)];
    final ln = lastNames[rng.nextInt(lastNames.length)];
    return '$fn $ln';
  }

  String _genLocation(String original, Random rng) {
    const cities = [
      'Springfield', 'Riverside', 'Fairview', 'Madison',
      'Oakland', 'Georgetown', 'Burlington', 'Clinton',
    ];
    return cities[rng.nextInt(cities.length)];
  }

  String _genDate(String original, Random rng) {
    return preserveDateFormat(original, rng: rng);
  }

  String _genAge(String original, Random rng) {
    return rng.nextInt(90).toString();
  }

  /// Register the built-in label->generator mappings.
  void _registerDefaults() {
    _generators['person'] = _genName;
    _generators['firstName'] = _genName;
    _generators['lastName'] = _genName;
    _generators['phone'] = _genPhone;
    _generators['PHONE_NUMBER'] = _genPhone;
    _generators['email'] = _genEmail;
    _generators['ssn'] = _genSsn;
    _generators['creditCard'] = _genCreditCard;
    _generators['CREDIT_DEBIT_CARD'] = _genCreditCard;
    _generators['date'] = _genDate;
    _generators['dateOfBirth'] = _genDate;
    _generators['age'] = _genAge;
    _generators['location'] = _genLocation;
    _generators['streetAddress'] = _genLocation;
    _generators['city'] = _genLocation;
    _generators['country'] = _genLocation;
  }

  /// Returns a random digit string of [length].
  String _randomDigits(int length, Random rng) {
    return List.generate(length, (_) => String.fromCharCode(0x30 + rng.nextInt(10))).join();
  }

  /// Returns a random lowercase string of [length].
  String _randomString(int length, Random rng) {
    return List.generate(length, (_) {
      return String.fromCharCode(0x61 + rng.nextInt(26));
    }).join();
  }
}
