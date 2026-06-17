import 'package:equatable/equatable.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

abstract class MedicationsState extends Equatable {
  const MedicationsState();

  @override
  List<Object?> get props => [];
}

class MedicationsInitial extends MedicationsState {
  const MedicationsInitial();
}

class MedicationsLoading extends MedicationsState {
  const MedicationsLoading();
}

class MedicationsLoaded extends MedicationsState {
  final List<Medication> medications;

  const MedicationsLoaded(this.medications);

  @override
  List<Object?> get props => [medications];
}

class MedicationsError extends MedicationsState {
  final String message;

  const MedicationsError(this.message);

  @override
  List<Object?> get props => [message];
}
