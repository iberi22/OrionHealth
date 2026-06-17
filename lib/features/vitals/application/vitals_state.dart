import 'package:equatable/equatable.dart';
import '../domain/entities/vital_sign.dart';

abstract class VitalsState extends Equatable {
  const VitalsState();

  @override
  List<Object?> get props => [];
}

class VitalsInitial extends VitalsState {
  const VitalsInitial();
}

class VitalsLoading extends VitalsState {
  const VitalsLoading();
}

class VitalsLoaded extends VitalsState {
  final List<VitalSign> vitals;
  const VitalsLoaded(this.vitals);

  @override
  List<Object?> get props => [vitals];
}

class VitalsLatestLoaded extends VitalsState {
  final Map<VitalSignType, VitalSign?> latest;
  const VitalsLatestLoaded(this.latest);

  @override
  List<Object?> get props => [latest];
}

class VitalsError extends VitalsState {
  final String message;
  const VitalsError(this.message);

  @override
  List<Object?> get props => [message];
}
