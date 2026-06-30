import 'package:equatable/equatable.dart';

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

// ============== state CLASSES ==============

abstract class HealthImportState extends Equatable {
  const HealthImportState();

  @override
  List<Object?> get props => [];
}

class HealthImportInitial extends HealthImportState {
  const HealthImportInitial();
}

class HealthImportLoading extends HealthImportState {
  const HealthImportLoading();
}

class HealthImportReady extends HealthImportState {
  final List<HealthDataSource> availableSources;
  final Map<HealthDataSource, bool> availability;

  const HealthImportReady({
    required this.availableSources,
    required this.availability,
  });

  @override
  List<Object?> get props => [availableSources, availability];
}

class HealthImportAuthenticating extends HealthImportState {
  final HealthDataSource source;

  const HealthImportAuthenticating(this.source);

  @override
  List<Object?> get props => [source];
}

class HealthImportImporting extends HealthImportState {
  final HealthDataSource source;
  final String currentStep;
  final int totalSteps;
  final int currentStepNum;
  final int importedCount;

  const HealthImportImporting({
    required this.source,
    required this.currentStep,
    required this.totalSteps,
    required this.currentStepNum,
    required this.importedCount,
  });

  double get progress => totalSteps > 0 ? currentStepNum / totalSteps : 0;

  @override
  List<Object?> get props => [
        source,
        currentStep,
        totalSteps,
        currentStepNum,
        importedCount,
      ];
}

class HealthImportSuccess extends HealthImportState {
  final int importedCount;
  final HealthDataSource source;

  const HealthImportSuccess({
    required this.importedCount,
    required this.source,
  });

  @override
  List<Object?> get props => [importedCount, source];
}

class HealthImportError extends HealthImportState {
  final String message;

  const HealthImportError(this.message);

  @override
  List<Object?> get props => [message];
}
