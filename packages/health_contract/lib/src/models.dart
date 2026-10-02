import 'validation.dart';

/// Typed payload of a SWAL health envelope.
sealed class HealthData {
  const HealthData();
  Map<String, dynamic> toJson();
}

class Source {
  const Source({required this.app, required this.version});
  final String app;
  final String version;
  factory Source.fromJson(Map<String, dynamic> json) =>
      Source(app: json['app'] as String, version: json['version'] as String);
  Map<String, dynamic> toJson() => {'app': app, 'version': version};
}

class MealItem {
  const MealItem({required this.ref, this.grams, this.servings});
  final String ref;
  final num? grams;
  final num? servings;
  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
    ref: json['ref'] as String,
    grams: json['grams'] as num?,
    servings: json['servings'] as num?,
  );
  Map<String, dynamic> toJson() => {
    'ref': ref,
    if (grams != null) 'grams': grams,
    if (servings != null) 'servings': servings,
  };
}

class Nutrition {
  Nutrition({
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.fiberG,
    required this.sugarG,
    required Map<String, num> micros,
  }) : micros = Map.unmodifiable(micros);
  final num calories;
  final num proteinG;
  final num fatG;
  final num carbsG;
  final num fiberG;
  final num sugarG;
  final Map<String, num> micros;
  factory Nutrition.fromJson(Map<String, dynamic> json) => Nutrition(
    calories: json['calories'] as num,
    proteinG: json['protein_g'] as num,
    fatG: json['fat_g'] as num,
    carbsG: json['carbs_g'] as num,
    fiberG: json['fiber_g'] as num,
    sugarG: json['sugar_g'] as num,
    micros: Map<String, num>.from(json['micros'] as Map),
  );
  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein_g': proteinG,
    'fat_g': fatG,
    'carbs_g': carbsG,
    'fiber_g': fiberG,
    'sugar_g': sugarG,
    'micros': micros,
  };
}

class MealOrigin {
  const MealOrigin({required this.app, this.venue, this.orderId});
  final String app;
  final String? venue;
  final String? orderId;
  factory MealOrigin.fromJson(Map<String, dynamic> json) => MealOrigin(
    app: json['app'] as String,
    venue: json['venue'] as String?,
    orderId: json['orderId'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'app': app,
    if (venue != null) 'venue': venue,
    if (orderId != null) 'orderId': orderId,
  };
}

class MealLog extends HealthData {
  MealLog({
    required this.consumedAt,
    required this.mealType,
    required List<MealItem> items,
    required this.nutrition,
    required this.nutritionSource,
    required this.origin,
  }) : items = List.unmodifiable(items);
  final String consumedAt;
  final String mealType;
  final List<MealItem> items;
  final Nutrition nutrition;
  final String nutritionSource;
  final MealOrigin origin;
  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog(
    consumedAt: json['consumedAt'] as String,
    mealType: json['mealType'] as String,
    items: (json['items'] as List)
        .map((e) => MealItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    nutrition: Nutrition.fromJson(
      Map<String, dynamic>.from(json['nutrition'] as Map),
    ),
    nutritionSource: json['nutritionSource'] as String,
    origin: MealOrigin.fromJson(
      Map<String, dynamic>.from(json['origin'] as Map),
    ),
  );
  @override
  Map<String, dynamic> toJson() => {
    'consumedAt': consumedAt,
    'mealType': mealType,
    'items': items.map((e) => e.toJson()).toList(),
    'nutrition': nutrition.toJson(),
    'nutritionSource': nutritionSource,
    'origin': origin.toJson(),
  };
}

class ExerciseSet {
  const ExerciseSet({
    this.reps,
    this.weightKg,
    this.rpe,
    this.durationS,
    this.distanceM,
  });
  final num? reps;
  final num? weightKg;
  final num? rpe;
  final num? durationS;
  final num? distanceM;
  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    reps: json['reps'] as num?,
    weightKg: json['weightKg'] as num?,
    rpe: json['rpe'] as num?,
    durationS: json['durationS'] as num?,
    distanceM: json['distanceM'] as num?,
  );
  Map<String, dynamic> toJson() => {
    if (reps != null) 'reps': reps,
    if (weightKg != null) 'weightKg': weightKg,
    if (rpe != null) 'rpe': rpe,
    if (durationS != null) 'durationS': durationS,
    if (distanceM != null) 'distanceM': distanceM,
  };
}

class WorkoutExercise {
  WorkoutExercise({required this.ref, required List<ExerciseSet> sets})
    : sets = List.unmodifiable(sets);
  final String ref;
  final List<ExerciseSet> sets;
  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutExercise(
        ref: json['ref'] as String,
        sets: (json['sets'] as List)
            .map(
              (e) => ExerciseSet.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList(),
      );
  Map<String, dynamic> toJson() => {
    'ref': ref,
    'sets': sets.map((e) => e.toJson()).toList(),
  };
}

class WorkoutEnergy {
  const WorkoutEnergy({required this.kcal, required this.method});
  final num kcal;
  final String method;
  factory WorkoutEnergy.fromJson(Map<String, dynamic> json) => WorkoutEnergy(
    kcal: json['kcal'] as num,
    method: json['method'] as String,
  );
  Map<String, dynamic> toJson() => {'kcal': kcal, 'method': method};
}

class WorkoutSession extends HealthData {
  WorkoutSession({
    required this.startedAt,
    required this.endedAt,
    this.routineId,
    required List<WorkoutExercise> exercises,
    this.energy,
    this.perceivedEffort,
    this.notes,
  }) : exercises = List.unmodifiable(exercises);
  final String startedAt;
  final String endedAt;
  final String? routineId;
  final List<WorkoutExercise> exercises;
  final WorkoutEnergy? energy;
  final num? perceivedEffort;
  final String? notes;
  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    startedAt: json['startedAt'] as String,
    endedAt: json['endedAt'] as String,
    routineId: json['routineId'] as String?,
    exercises: (json['exercises'] as List)
        .map(
          (e) => WorkoutExercise.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    energy: json['energy'] == null
        ? null
        : WorkoutEnergy.fromJson(
            Map<String, dynamic>.from(json['energy'] as Map),
          ),
    perceivedEffort: json['perceivedEffort'] as num?,
    notes: json['notes'] as String?,
  );
  @override
  Map<String, dynamic> toJson() => {
    'startedAt': startedAt,
    'endedAt': endedAt,
    if (routineId != null) 'routineId': routineId,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    if (energy != null) 'energy': energy?.toJson(),
    if (perceivedEffort != null) 'perceivedEffort': perceivedEffort,
    if (notes != null) 'notes': notes,
  };
}

class DietaryTargets {
  const DietaryTargets({this.kcalPerDay, this.proteinGPerDay});
  final num? kcalPerDay;
  final num? proteinGPerDay;
  factory DietaryTargets.fromJson(Map<String, dynamic> json) => DietaryTargets(
    kcalPerDay: json['kcalPerDay'] as num?,
    proteinGPerDay: json['proteinGPerDay'] as num?,
  );
  Map<String, dynamic> toJson() => {
    if (kcalPerDay != null) 'kcalPerDay': kcalPerDay,
    if (proteinGPerDay != null) 'proteinGPerDay': proteinGPerDay,
  };
}

class DietaryProfile extends HealthData {
  DietaryProfile({
    required List<String> allergens,
    required List<String> diets,
    required this.targets,
    required this.expiresAt,
  }) : allergens = List.unmodifiable(allergens),
       diets = List.unmodifiable(diets);
  final List<String> allergens;
  final List<String> diets;
  final DietaryTargets targets;
  final String expiresAt;
  factory DietaryProfile.fromJson(Map<String, dynamic> json) => DietaryProfile(
    allergens: List<String>.from(json['allergens'] as List),
    diets: List<String>.from(json['diets'] as List),
    targets: DietaryTargets.fromJson(
      Map<String, dynamic>.from(json['targets'] as Map),
    ),
    expiresAt: json['expiresAt'] as String,
  );
  @override
  Map<String, dynamic> toJson() => {
    'allergens': allergens,
    'diets': diets,
    'targets': targets.toJson(),
    'expiresAt': expiresAt,
  };
}

/// Dates remain wire strings so offsets and fractional precision round-trip.
class Envelope {
  const Envelope({
    required this.schema,
    required this.id,
    required this.subject,
    required this.createdAt,
    required this.source,
    required this.gosDataset,
    required this.data,
  });
  final String schema;
  final String id;
  final String subject;
  final String createdAt;
  final Source source;
  final String gosDataset;
  final HealthData data;
  String get type => schema.split('/').last;
  factory Envelope.fromJson(Map<String, dynamic> json) {
    final result = validateRecord(json);
    if (!result.ok) throw ContractValidationError(result.errors);
    final payload = Map<String, dynamic>.from(json['data'] as Map);
    final HealthData data = switch (json['schema']) {
      'swal.health/v1/meal-log' => MealLog.fromJson(payload),
      'swal.health/v1/workout-session' => WorkoutSession.fromJson(payload),
      _ => DietaryProfile.fromJson(payload),
    };
    return Envelope(
      schema: json['schema'] as String,
      id: json['id'] as String,
      subject: json['subject'] as String,
      createdAt: json['createdAt'] as String,
      source: Source.fromJson(Map<String, dynamic>.from(json['source'] as Map)),
      gosDataset: json['gosDataset'] as String,
      data: data,
    );
  }
  Map<String, dynamic> toJson() => {
    'schema': schema,
    'id': id,
    'subject': subject,
    'createdAt': createdAt,
    'source': source.toJson(),
    'gosDataset': gosDataset,
    'data': data.toJson(),
  };
}
