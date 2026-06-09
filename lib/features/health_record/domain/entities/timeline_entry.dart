import 'package:equatable/equatable.dart';

enum TimelineEntryType {
  labResult,
  vitalSign,
  medication,
  medicalEvent,
  medicalConcept,
  clinicalNote,
}

class TimelineEntry extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final TimelineEntryType type;
  final Map<String, dynamic>? metadata;

  const TimelineEntry({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.type,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, title, description, date, type, metadata];
}
