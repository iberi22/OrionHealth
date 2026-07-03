/// Represents a health data source (Google Fit/Health Connect, Apple Health)
enum HealthDataSource {
  googleFit,
  appleHealth,
  samsungHealth,
}

extension HealthDataSourceExtension on HealthDataSource {
  String get displayName {
    switch (this) {
      case HealthDataSource.googleFit:
        return 'Google Fit / Health Connect';
      case HealthDataSource.appleHealth:
        return 'Apple Health';
      case HealthDataSource.samsungHealth:
        return 'Samsung Health';
    }
  }

  String get sourceKey {
    switch (this) {
      case HealthDataSource.googleFit:
        return 'google_fit';
      case HealthDataSource.appleHealth:
        return 'apple_health';
      case HealthDataSource.samsungHealth:
        return 'samsung_health';
    }
  }
}
