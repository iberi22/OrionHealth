import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/timeline_entry.dart';

void main() {
  group('TimelineEntry', () {
    final testDate = DateTime(2025, 1, 1);

    test('should create TimelineEntry with provided values', () {
      final entry = TimelineEntry(
        id: '1',
        title: 'Lab Result',
        description: 'Blood test',
        date: testDate,
        type: TimelineEntryType.labResult,
        metadata: const {'key': 'value'},
      );

      expect(entry.id, '1');
      expect(entry.title, 'Lab Result');
      expect(entry.description, 'Blood test');
      expect(entry.date, testDate);
      expect(entry.type, TimelineEntryType.labResult);
      expect(entry.metadata, const {'key': 'value'});
    });

    test('should support value equality', () {
      final entry1 = TimelineEntry(
        id: '1',
        title: 'Lab Result',
        date: testDate,
        type: TimelineEntryType.labResult,
      );
      final entry2 = TimelineEntry(
        id: '1',
        title: 'Lab Result',
        date: testDate,
        type: TimelineEntryType.labResult,
      );
      final entry3 = TimelineEntry(
        id: '2',
        title: 'Lab Result',
        date: testDate,
        type: TimelineEntryType.labResult,
      );

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
      expect(entry1.hashCode, equals(entry2.hashCode));
    });

    test('should handle null description and metadata', () {
      final entry = TimelineEntry(
        id: '1',
        title: 'Title',
        date: testDate,
        type: TimelineEntryType.labResult,
      );

      expect(entry.description, isNull);
      expect(entry.metadata, isNull);
    });

    test('should handle empty metadata', () {
      final entry = TimelineEntry(
        id: '1',
        title: 'Title',
        date: testDate,
        type: TimelineEntryType.labResult,
        metadata: const {},
      );

      expect(entry.metadata, isEmpty);
    });

    test('should support all TimelineEntryType values', () {
      for (final type in TimelineEntryType.values) {
        final entry = TimelineEntry(
          id: 'id_${type.name}',
          title: 'Title ${type.name}',
          date: testDate,
          type: type,
        );
        expect(entry.type, type);
      }
    });

    test('should have correct props', () {
      final entry = TimelineEntry(
        id: '1',
        title: 'Lab Result',
        description: 'Blood test',
        date: testDate,
        type: TimelineEntryType.labResult,
        metadata: const {'key': 'value'},
      );

      expect(entry.props, [
        '1',
        'Lab Result',
        'Blood test',
        testDate,
        TimelineEntryType.labResult,
        {'key': 'value'},
      ]);
    });
  });
}
