/// Represents a device calendar source that can be scanned for medical events.
///
/// Each calendar on the device (e.g., "Personal", "Work", "Medical") is
/// represented by one of these entities.
class CalendarSource {
  final String id;
  final String name;
  final bool isReadOnly;
  final bool isPrimary;

  const CalendarSource({
    required this.id,
    required this.name,
    this.isReadOnly = false,
    this.isPrimary = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarSource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CalendarSource(id: $id, name: $name)';
}
