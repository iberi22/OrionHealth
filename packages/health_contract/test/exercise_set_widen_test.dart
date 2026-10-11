import 'package:health_contract/health_contract.dart';
import 'package:test/test.dart';

void main() {
  group('ExerciseSet widening tests', () {
    test('ExerciseSet round-trips all properties to JSON', () {
      final set = ExerciseSet(
        reps: 8,
        weightKg: 40,
        rir: 2,
        distanceM: 100,
        speedKph: 10,
        phase: 'work',
        shape: 'dropset',
        drops: [SetDrop(weightKg: 30, reps: 6)],
        clusters: [SetCluster(reps: 3, restSec: 15)],
        sides: SetSides(
          left: SetSide(reps: 8, weightKg: 20),
          right: SetSide(reps: 8, weightKg: 20),
        ),
      );

      final json = set.toJson();
      expect(json['speedKph'], 10);
      expect(json['rir'], 2);
      expect(json['drops'], isNotEmpty);
      expect(json['clusters'], isNotEmpty);
      expect(json['sides'], isNotNull);
      expect((json['sides'] as Map)['L'], isNotNull);
      expect((json['sides'] as Map)['R'], isNotNull);

      final set2 = ExerciseSet.fromJson(json);
      expect(set2.toJson(), equals(json));

      expect(set2.sides!.left.reps, 8);
      expect(set2.sides!.right.weightKg, 20);
    });

    test('ExerciseSet with only reps produces minimal JSON', () {
      final set = ExerciseSet(reps: 5);
      final json = set.toJson();

      expect(json.containsKey('reps'), isTrue);
      expect(json.containsKey('rir'), isFalse);
      expect(json.containsKey('speedKph'), isFalse);
      expect(json.containsKey('phase'), isFalse);
      expect(json.containsKey('shape'), isFalse);
      expect(json.containsKey('drops'), isFalse);
      expect(json.containsKey('clusters'), isFalse);
      expect(json.containsKey('sides'), isFalse);
    });

    test('ExerciseSet lists are unmodifiable', () {
      final set = ExerciseSet(
        reps: 8,
        drops: [SetDrop(weightKg: 30, reps: 6)],
        clusters: [SetCluster(reps: 3, restSec: 15)],
      );

      expect(
        () => set.drops!.add(SetDrop(weightKg: 20, reps: 5)),
        throwsA(isA<UnsupportedError>()),
      );

      expect(
        () => set.clusters!.add(SetCluster(reps: 2, restSec: 10)),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
