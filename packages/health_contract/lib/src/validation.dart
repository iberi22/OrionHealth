/// Closed allergen vocabulary from the canonical v1 schema.
const allergens = [
  'celery',
  'crustacean',
  'egg',
  'fish',
  'gluten',
  'lupin',
  'milk',
  'mollusc',
  'mustard',
  'peanut',
  'sesame',
  'soy',
  'sulphite',
  'tree-nut',
];

class ValidationResult {
  ValidationResult(List<String> errors) : errors = List.unmodifiable(errors);
  final List<String> errors;
  bool get ok => errors.isEmpty;
}

class ContractValidationError implements Exception {
  ContractValidationError(List<String> errors)
    : errors = List.unmodifiable(errors);
  final List<String> errors;
  @override
  String toString() => 'Invalid swal.health/v1 data: ${errors.join('; ')}';
}

const _slug = r'[a-z0-9]+(?:[-_][a-z0-9]+)*';
final _ulid = RegExp(r'^[0-7][0-9A-HJKMNP-TV-Z]{25}$');
final _date = RegExp(
  r'^(\d{4})-(\d{2})-(\d{2})[Tt](\d{2}):(\d{2}):(\d{2})(?:\.\d+)?([Zz]|[+-](\d{2}):(\d{2}))$',
);
final _version = RegExp(
  r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$',
);
final _dataset = RegExp(
  r'^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?\+sha256:[a-f0-9]{64}$',
);

bool _isDate(dynamic x) {
  if (x is! String) return false;
  final m = _date.firstMatch(x);
  if (m == null || m.end != x.length) return false;
  final v = List.generate(6, (i) => int.parse(m.group(i + 1)!));
  final y = v[0], month = v[1], day = v[2];
  final leap = y % 4 == 0 && (y % 100 != 0 || y % 400 == 0);
  final days = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return month >= 1 &&
      month <= 12 &&
      day >= 1 &&
      day <= days[month - 1] &&
      v[3] <= 23 &&
      v[4] <= 59 &&
      v[5] <= 59 &&
      int.parse(m.group(8) ?? '0') <= 23 &&
      int.parse(m.group(9) ?? '0') <= 59;
}

/// Mirrors the reference TS validator, including JSON Pointer error paths.
/// Temporal order, expiration and subject consent are application concerns.
ValidationResult validateRecord(dynamic input) {
  final v = _Validator();
  v.record(input);
  return ValidationResult(v.errors);
}

class _Validator {
  final errors = <String>[];
  void fail(String p, String message) =>
      errors.add('${p.isEmpty ? '/' : p}: $message');
  bool object(
    dynamic x,
    String p,
    List<String> allowed, [
    List<String>? required,
  ]) {
    if (x is! Map) {
      fail(p, 'expected object');
      return false;
    }
    for (final key in x.keys) {
      if (!allowed.contains(key)) fail('$p/$key', 'unknown property');
    }
    for (final key in required ?? allowed) {
      if (!x.containsKey(key)) fail('$p/$key', 'required property');
    }
    return true;
  }

  void string(dynamic x, String p, [RegExp? pattern, bool nonempty = false]) {
    if (x is! String ||
        (nonempty && x.isEmpty) ||
        (pattern != null && !pattern.hasMatch(x))) {
      fail(p, 'invalid string');
    }
  }

  void enumeration(dynamic x, String p, List<String> values) {
    if (x is! String || !values.contains(x)) fail(p, 'unsupported value');
  }

  void number(
    dynamic x,
    String p, [
    bool positive = false,
    num max = double.infinity,
    bool integer = false,
  ]) {
    if (x is! num ||
        !x.isFinite ||
        (positive ? x <= 0 : x < 0) ||
        x > max ||
        (integer && x % 1 != 0)) {
      fail(p, 'invalid number');
    }
  }

  void date(dynamic x, String p) {
    if (!_isDate(x)) fail(p, 'invalid ISO date-time');
  }

  void array(
    dynamic x,
    String p,
    void Function(dynamic, String) visit, [
    int min = 0,
    bool unique = false,
  ]) {
    if (x is! List) {
      fail(p, 'expected array');
      return;
    }
    if (x.length < min) fail(p, 'empty array');
    if (unique && x.toSet().length != x.length) fail(p, 'duplicate value');
    for (var i = 0; i < x.length; i++) {
      visit(x[i], '$p/$i');
    }
  }

  void record(dynamic input) {
    if (!object(input, '', [
      'schema',
      'id',
      'subject',
      'createdAt',
      'source',
      'gosDataset',
      'data',
    ]))
      return;
    final x = input as Map;
    enumeration(x['schema'], '/schema', [
      'swal.health/v1/meal-log',
      'swal.health/v1/workout-session',
      'swal.health/v1/dietary-profile',
    ]);
    string(x['id'], '/id', _ulid);
    string(
      x['subject'],
      '/subject',
      RegExp(r'^subj_[0-7][0-9A-HJKMNP-TV-Z]{25}$'),
    );
    date(x['createdAt'], '/createdAt');
    string(x['gosDataset'], '/gosDataset', _dataset);
    if (object(x['source'], '/source', ['app', 'version'])) {
      enumeration(x['source']['app'], '/source/app', [
        'fize',
        'training',
        'orionhealth',
        'gos',
      ]);
      string(x['source']['version'], '/source/version', _version);
    }
    switch (x['schema']) {
      case 'swal.health/v1/meal-log':
        meal(x['data']);
      case 'swal.health/v1/workout-session':
        workout(x['data']);
      case 'swal.health/v1/dietary-profile':
        profile(x['data']);
    }
  }

  void meal(dynamic d) {
    if (!object(d, '/data', [
      'consumedAt',
      'mealType',
      'items',
      'nutrition',
      'nutritionSource',
      'origin',
    ]))
      return;
    date(d['consumedAt'], '/data/consumedAt');
    enumeration(d['mealType'], '/data/mealType', [
      'breakfast',
      'lunch',
      'dinner',
      'snack',
    ]);
    enumeration(d['nutritionSource'], '/data/nutritionSource', [
      'computed',
      'declared',
      'unknown',
    ]);
    array(d['items'], '/data/items', (dynamic item, p) {
      if (!object(item, p, ['ref', 'servings', 'grams'], ['ref'])) return;
      string(
        item['ref'],
        '$p/ref',
        RegExp('^gos:(?:ingredient/$_slug|dish/$_slug/$_slug)\$'),
      );
      if ((item as Map).containsKey('grams') == item.containsKey('servings'))
        fail(p, 'exactly one of grams or servings required');
      for (final k in ['grams', 'servings']) {
        if (item.containsKey(k)) number(item[k], '$p/$k', true);
      }
    }, 1);
    const keys = [
      'calories',
      'protein_g',
      'fat_g',
      'carbs_g',
      'fiber_g',
      'sugar_g',
      'micros',
    ];
    if (object(d['nutrition'], '/data/nutrition', keys)) {
      for (final k in keys.take(6)) {
        number(d['nutrition'][k], '/data/nutrition/$k');
      }
      final micros = d['nutrition']['micros'];
      if (micros is Map) {
        for (final e in micros.entries) {
          string(e.key, '/data/nutrition/micros/${e.key}', RegExp('^$_slug\$'));
          number(e.value, '/data/nutrition/micros/${e.key}');
        }
      } else {
        fail('/data/nutrition/micros', 'expected object');
      }
    }
    if (object(
      d['origin'],
      '/data/origin',
      ['app', 'venue', 'orderId'],
      ['app'],
    )) {
      enumeration(d['origin']['app'], '/data/origin/app', [
        'fize',
        'orionhealth',
        'gos',
      ]);
      for (final k in ['venue', 'orderId']) {
        if ((d['origin'] as Map).containsKey(k))
          string(d['origin'][k], '/data/origin/$k', null, true);
      }
    }
  }

  void workout(dynamic d) {
    if (!object(
      d,
      '/data',
      [
        'startedAt',
        'endedAt',
        'routineId',
        'exercises',
        'energy',
        'perceivedEffort',
        'notes',
      ],
      ['startedAt', 'endedAt', 'exercises'],
    ))
      return;
    date(d['startedAt'], '/data/startedAt');
    date(d['endedAt'], '/data/endedAt');
    if ((d as Map).containsKey('routineId'))
      string(d['routineId'], '/data/routineId', null, true);
    if (d.containsKey('notes')) string(d['notes'], '/data/notes');
    if (d.containsKey('perceivedEffort'))
      number(d['perceivedEffort'], '/data/perceivedEffort', false, 10);
    if (d.containsKey('energy') &&
        object(d['energy'], '/data/energy', ['kcal', 'method'])) {
      number(d['energy']['kcal'], '/data/energy/kcal');
      enumeration(d['energy']['method'], '/data/energy/method', [
        'met-estimate',
        'device',
        'declared',
        'unknown',
      ]);
    }
    array(d['exercises'], '/data/exercises', (dynamic e, p) {
      if (!object(e, p, ['ref', 'sets'])) return;
      string(e['ref'], '$p/ref', RegExp('^wg:$_slug\$'));
      array(e['sets'], '$p/sets', (dynamic s, sp) {
        if (!object(s, sp, [
          'reps',
          'weightKg',
          'rpe',
          'durationS',
          'distanceM',
        ], []))
          return;
        if (![
          'reps',
          'durationS',
          'distanceM',
        ].any((k) => (s as Map).containsKey(k)))
          fail(sp, 'reps, durationS or distanceM required');
        for (final k in ['reps', 'durationS', 'distanceM']) {
          if ((s as Map).containsKey(k))
            number(s[k], '$sp/$k', true, double.infinity, k == 'reps');
        }
        if ((s as Map).containsKey('weightKg'))
          number(s['weightKg'], '$sp/weightKg');
        if (s.containsKey('rpe')) number(s['rpe'], '$sp/rpe', false, 10);
      }, 1);
    }, 1);
  }

  void profile(dynamic d) {
    if (!object(d, '/data', ['allergens', 'diets', 'targets', 'expiresAt']))
      return;
    array(
      d['allergens'],
      '/data/allergens',
      (v, p) =>
          enumeration(v, p, allergens.map((a) => 'gos:allergen/$a').toList()),
      0,
      true,
    );
    array(
      d['diets'],
      '/data/diets',
      (v, p) => string(v, p, RegExp('^gos:diet/$_slug\$')),
      0,
      true,
    );
    date(d['expiresAt'], '/data/expiresAt');
    if (object(d['targets'], '/data/targets', [
      'kcalPerDay',
      'proteinGPerDay',
    ], [])) {
      if ((d['targets'] as Map).containsKey('kcalPerDay'))
        number(d['targets']['kcalPerDay'], '/data/targets/kcalPerDay', true);
      if ((d['targets'] as Map).containsKey('proteinGPerDay'))
        number(d['targets']['proteinGPerDay'], '/data/targets/proteinGPerDay');
    }
  }
}
