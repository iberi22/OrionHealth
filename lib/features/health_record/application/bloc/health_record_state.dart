part of 'health_record_cubit.dart';

abstract class HealthRecordState extends Equatable {
  const HealthRecordState();

  @override
  List<Object?> get props => [];
}

class HealthRecordInitial extends HealthRecordState {}

class HealthRecordLoading extends HealthRecordState {}

class HealthRecordFilePicked extends HealthRecordState {
  final String filePath;
  final String extractedText;

  const HealthRecordFilePicked({required this.filePath, required this.extractedText});

  @override
  List<Object?> get props => [filePath, extractedText];
}

class HealthRecordSaved extends HealthRecordState {}

class HealthRecordLoaded extends HealthRecordState {
  final List<MedicalRecord> records;

  const HealthRecordLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class HealthRecordError extends HealthRecordState {
  final String message;

  const HealthRecordError(this.message);

  @override
  List<Object?> get props => [message];
}
