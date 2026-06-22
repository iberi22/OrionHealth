import 'package:isar/isar.dart';

part 'dashboard_preference.g.dart';

@collection
class DashboardPreference {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String key;

  String value;

  DashboardPreference({
    required this.key,
    required this.value,
  });
}
