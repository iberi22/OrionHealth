import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/calendar_import/infrastructure/models/calendar_source_dto.dart';
import 'package:orionhealth_health/features/calendar_import/domain/entities/calendar_source.dart';

void main() {
  group('CalendarSourceDto', () {
    group('toEntity', () {
      test('converts with all fields', () {
        const dto = CalendarSourceDto(
          id: '1',
          name: 'Work',
          isReadOnly: true,
          isPrimary: true,
        );
        final entity = dto.toEntity();
        expect(entity.id, '1');
        expect(entity.name, 'Work');
        expect(entity.isReadOnly, isTrue);
        expect(entity.isPrimary, isTrue);
      });

      test('converts with default flags', () {
        const dto = CalendarSourceDto(id: '2', name: 'Personal');
        final entity = dto.toEntity();
        expect(entity.isReadOnly, isFalse);
        expect(entity.isPrimary, isFalse);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const dto = CalendarSourceDto(
          id: '1',
          name: 'Work',
          isReadOnly: true,
          isPrimary: true,
        );
        final json = dto.toJson();
        expect(json['id'], '1');
        expect(json['name'], 'Work');
        expect(json['isReadOnly'], isTrue);
        expect(json['isPrimary'], isTrue);
      });

      test('serializes defaults', () {
        const dto = CalendarSourceDto(id: '2', name: 'Personal');
        final json = dto.toJson();
        expect(json['isReadOnly'], isFalse);
        expect(json['isPrimary'], isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes full json', () {
        final json = {
          'id': '3',
          'name': 'Holidays',
          'isReadOnly': false,
          'isPrimary': true,
        };
        final dto = CalendarSourceDto.fromJson(json);
        expect(dto.id, '3');
        expect(dto.name, 'Holidays');
        expect(dto.isReadOnly, isFalse);
        expect(dto.isPrimary, isTrue);
      });

      test('json roundtrip', () {
        const dto = CalendarSourceDto(
          id: '4',
          name: 'Family',
          isReadOnly: false,
          isPrimary: true,
        );
        final json = dto.toJson();
        final restored = CalendarSourceDto.fromJson(json);
        expect(restored.id, '4');
        expect(restored.name, 'Family');
        expect(restored.isPrimary, isTrue);
      });

      test('handles missing boolean fields', () {
        final json = {'id': '5', 'name': 'Test'};
        final dto = CalendarSourceDto.fromJson(json);
        expect(dto.isReadOnly, isFalse);
        expect(dto.isPrimary, isFalse);
      });
    });

    // Note: fromDeviceCalendar requires device_calendar.Calendar which needs
    // the package. Tested via CalendarEventDto.fromDeviceCalendar using mock data.
  });
}
