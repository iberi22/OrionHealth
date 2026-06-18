import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_source.dart';

void main() {
  group('CalendarSource', () {
    test('supports value equality by id', () {
      expect(
        const CalendarSource(id: 'cal-1', name: 'Personal'),
        const CalendarSource(id: 'cal-1', name: 'Personal'),
      );
    });

    test('same id equals even with different name', () {
      expect(
        const CalendarSource(id: 'cal-1', name: 'Personal'),
        const CalendarSource(id: 'cal-1', name: 'Work'), // same id
      );
    });

    test('different id does not equal', () {
      expect(
        const CalendarSource(id: 'cal-1', name: 'Personal'),
        isNot(equals(const CalendarSource(id: 'cal-2', name: 'Personal'))),
      );
    });

    test('default values are correct', () {
      final source = const CalendarSource(id: 'test', name: 'Test');
      expect(source.isReadOnly, false);
      expect(source.isPrimary, false);
    });

    test('read only can be set', () {
      final source = const CalendarSource(
        id: 'test',
        name: 'Test',
        isReadOnly: true,
      );
      expect(source.isReadOnly, true);
    });

    test('primary can be set', () {
      final source = const CalendarSource(
        id: 'test',
        name: 'Test',
        isPrimary: true,
      );
      expect(source.isPrimary, true);
    });

    test('toString is human readable', () {
      final source = const CalendarSource(id: 'cal-id', name: 'My Calendar');
      expect(
        source.toString(),
        'CalendarSource(id: cal-id, name: My Calendar)',
      );
    });
  });
}
