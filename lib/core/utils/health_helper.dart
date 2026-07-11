import 'package:health/health.dart';

class HealthHelper {
  /// Safely creates a Health client.
  ///
  /// Returns null if the Health client cannot be instantiated (e.g., on devices
  /// where Health Connect is not available and the constructor throws).
  static Health? createClient() {
    try {
      return Health();
    } catch (e) {
      // Log error or handle it silently
      return null;
    }
  }
}
