import 'package:health/health.dart';

class HealthWrapper {
  final Health? health;

  HealthWrapper(this.health);

  bool get isAvailable => health != null;
}
