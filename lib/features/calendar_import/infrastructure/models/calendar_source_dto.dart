import 'package:device_calendar/device_calendar.dart';
import '../../domain/entities/calendar_source.dart';

class CalendarSourceDto {
  final String id;
  final String name;
  final bool isReadOnly;
  final bool isPrimary;

  const CalendarSourceDto({
    required this.id,
    required this.name,
    this.isReadOnly = false,
    this.isPrimary = false,
  });

  factory CalendarSourceDto.fromDeviceCalendar(Calendar calendar) {
    return CalendarSourceDto(
      id: calendar.id ?? '',
      name: calendar.name ?? '',
      isReadOnly: calendar.isReadOnly ?? false,
      isPrimary: false, // device_calendar 4.3.3 might not have isPrimary
    );
  }

  CalendarSource toEntity() {
    return CalendarSource(
      id: id,
      name: name,
      isReadOnly: isReadOnly,
      isPrimary: isPrimary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isReadOnly': isReadOnly,
        'isPrimary': isPrimary,
      };

  factory CalendarSourceDto.fromJson(Map<String, dynamic> json) =>
      CalendarSourceDto(
        id: json['id'] as String,
        name: json['name'] as String,
        isReadOnly: json['isReadOnly'] as bool? ?? false,
        isPrimary: json['isPrimary'] as bool? ?? false,
      );
}
