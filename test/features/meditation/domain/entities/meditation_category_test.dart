import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';

void main() {
  group('MeditationCategory', () {
    test('has all expected values', () {
      expect(MeditationCategory.values, hasLength(4));
      expect(
        MeditationCategory.values,
        containsAll([
          MeditationCategory.calm,
          MeditationCategory.focus,
          MeditationCategory.sleep,
          MeditationCategory.breathing,
        ]),
      );
    });

    test('name accessor works', () {
      expect(MeditationCategory.calm.name, 'calm');
      expect(MeditationCategory.focus.name, 'focus');
      expect(MeditationCategory.sleep.name, 'sleep');
      expect(MeditationCategory.breathing.name, 'breathing');
    });
  });
}
