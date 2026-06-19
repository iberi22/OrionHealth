import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_preferences.dart';

void main() {
  group('MeditationPreferences', () {
    test('creates with defaults', () {
      const prefs = MeditationPreferences();

      expect(prefs.preferredCategory, MeditationCategory.calm);
      expect(prefs.preferredDurationMinutes, 5);
      expect(prefs.ttsEnabled, isTrue);
      expect(prefs.lastScriptId, isNull);
    });

    test('supports value equality', () {
      expect(
        const MeditationPreferences(
          preferredCategory: MeditationCategory.sleep,
          preferredDurationMinutes: 10,
          ttsEnabled: false,
          lastScriptId: '1',
        ),
        equals(const MeditationPreferences(
          preferredCategory: MeditationCategory.sleep,
          preferredDurationMinutes: 10,
          ttsEnabled: false,
          lastScriptId: '1',
        )),
      );
    });

    test('copyWith overrides specified fields', () {
      const prefs = MeditationPreferences();
      final modified = prefs.copyWith(
        preferredCategory: MeditationCategory.sleep,
        preferredDurationMinutes: 10,
        ttsEnabled: false,
        lastScriptId: 'sleep-01',
      );

      expect(modified.preferredCategory, MeditationCategory.sleep);
      expect(modified.preferredDurationMinutes, 10);
      expect(modified.ttsEnabled, isFalse);
      expect(modified.lastScriptId, 'sleep-01');
      // Original unchanged
      expect(prefs.preferredCategory, MeditationCategory.calm);
    });

    test('toJson and fromJson roundtrip', () {
      const prefs = MeditationPreferences(
        preferredCategory: MeditationCategory.focus,
        preferredDurationMinutes: 15,
        ttsEnabled: true,
        lastScriptId: 'focus-03',
      );

      final json = prefs.toJson();
      final restored = MeditationPreferences.fromJson(json);

      expect(restored.preferredCategory, prefs.preferredCategory);
      expect(restored.preferredDurationMinutes, prefs.preferredDurationMinutes);
      expect(restored.ttsEnabled, prefs.ttsEnabled);
      expect(restored.lastScriptId, prefs.lastScriptId);
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};
      final restored = MeditationPreferences.fromJson(json);

      expect(restored.preferredCategory, MeditationCategory.calm);
      expect(restored.preferredDurationMinutes, 5);
      expect(restored.ttsEnabled, isTrue);
      expect(restored.lastScriptId, isNull);
    });
  });
}
