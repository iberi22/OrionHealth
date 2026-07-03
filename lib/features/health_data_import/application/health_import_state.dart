import 'package:equatable/equatable.dart';
import '../domain/entities/health_data_source.dart';
import '../domain/entities/health_import_result.dart';

// ============== STATE CLASSES ==============

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
  final HealthImportResult result;

  const HealthImportSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class HealthImportError extends HealthImportState {
  final String message;

  const HealthImportError(this.message);

  @override
  List<Object?> get props => [message];
}
