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

  factory CalendarSourceDto.fromEntity(CalendarSource entity) {
    return CalendarSourceDto(
      id: entity.id,
      name: entity.name,
      isReadOnly: entity.isReadOnly,
      isPrimary: entity.isPrimary,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isReadOnly': isReadOnly,
      'isPrimary': isPrimary,
    };
  }

  factory CalendarSourceDto.fromJson(Map<String, dynamic> json) {
    return CalendarSourceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}
