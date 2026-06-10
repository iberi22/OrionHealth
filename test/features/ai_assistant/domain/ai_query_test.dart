import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/ai_assistant/domain/entities/ai_query.dart';

void main() {
  group('AiQuery', () {
    test('supports value comparisons', () {
      expect(
        const AiQuery(text: 'Hello'),
        const AiQuery(text: 'Hello'),
      );
    });

    test('copyWith creates a new instance with updated values', () {
      const query = AiQuery(text: 'Hello');
      final updated = query.copyWith(text: 'Hi');

      expect(updated.text, 'Hi');
      expect(updated.metadata, isNull);
    });

    test('metadata is preserved when copying other fields', () {
      const query = AiQuery(text: 'Hello', metadata: {'key': 'value'});
      final updated = query.copyWith(text: 'Hi');

      expect(updated.text, 'Hi');
      expect(updated.metadata, {'key': 'value'});
    });
  });
}
