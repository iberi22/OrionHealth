import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';

void main() {
  group('MeditationScript', () {
    const testScript = MeditationScript(
      id: 'breath-01',
      title: 'Respiración Profunda',
      category: MeditationCategory.breathing,
      durationMinutes: 5,
      steps: [
        'Siéntate cómodamente',
        'Inhala profundamente',
        'Exhala lentamente',
      ],
      tags: ['respiración', 'principiante'],
    );

    test('creates with required fields', () {
      expect(testScript.id, 'breath-01');
      expect(testScript.title, 'Respiración Profunda');
      expect(testScript.category, MeditationCategory.breathing);
      expect(testScript.durationMinutes, 5);
      expect(testScript.steps, hasLength(3));
    });

    test('supports value equality', () {
      expect(
        const MeditationScript(
          id: '1',
          title: 'Title',
          category: MeditationCategory.calm,
          durationMinutes: 5,
          steps: ['Step'],
        ),
        equals(const MeditationScript(
          id: '1',
          title: 'Title',
          category: MeditationCategory.calm,
          durationMinutes: 5,
          steps: ['Step'],
        )),
      );
    });

    test('default tags is empty', () {
      const noTags = MeditationScript(
        id: 'test',
        title: 'Test',
        category: MeditationCategory.calm,
        durationMinutes: 3,
        steps: ['Step 1'],
      );
      expect(noTags.tags, isEmpty);
    });

    test('toJson produces correct map', () {
      final json = testScript.toJson();

      expect(json['id'], 'breath-01');
      expect(json['title'], 'Respiración Profunda');
      expect(json['category'], 'breathing');
      expect(json['durationMinutes'], 5);
      expect(json['steps'], isA<List>());
      expect(json['steps'], hasLength(3));
      expect(json['tags'], hasLength(2));
    });

    test('fromJson reconstructs correctly', () {
      final json = testScript.toJson();
      final restored = MeditationScript.fromJson(json);

      expect(restored.id, testScript.id);
      expect(restored.title, testScript.title);
      expect(restored.category, testScript.category);
      expect(restored.durationMinutes, testScript.durationMinutes);
      expect(restored.steps, testScript.steps);
      expect(restored.tags, testScript.tags);
    });

    test('fromJson handles missing tags', () {
      final json = {
        'id': 'simple',
        'title': 'Simple',
        'category': 'calm',
        'durationMinutes': 3,
        'steps': ['Step'],
      };
      final restored = MeditationScript.fromJson(json);
      expect(restored.tags, isEmpty);
    });
  });
}
