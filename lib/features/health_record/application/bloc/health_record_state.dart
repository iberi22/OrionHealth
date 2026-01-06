part of 'health_record_cubit.dart';

abstract class HealthRecordState extends Equatable {
  const HealthRecordState();

  @override
  List<Object?> get props => [];
}

class HealthRecordInitial extends HealthRecordState {
  final List<MedicalRecord> records;

  const HealthRecordInitial({this.records = const []});

  @override
  List<Object?> get props => [records];
}

class HealthRecordLoading extends HealthRecordState {}

class HealthRecordLoadedState extends HealthRecordState {
  final List<MedicalRecord> records;

  const HealthRecordLoadedState({required this.records});

  @override
  List<Object?> get props => [records];
}

class HealthRecordFilePicked extends HealthRecordState {
  final String filePath;
  final String extractedText;

  const HealthRecordFilePicked({
    required this.filePath,
    required this.extractedText,
  });

  @override
  List<Object?> get props => [filePath, extractedText];
}

class HealthRecordSaved extends HealthRecordState {}

class HealthRecordError extends HealthRecordState {
  final String message;

  const HealthRecordError(this.message);

  @override
  List<Object?> get props => [message];
}
