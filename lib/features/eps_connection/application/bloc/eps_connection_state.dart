import 'package:equatable/equatable.dart';

sealed class EpsConnectionState extends Equatable {
  const EpsConnectionState();

  @override
  List<Object?> get props => [];
}

class EpsConnectionInitial extends EpsConnectionState {
  const EpsConnectionInitial();
}

class EpsConnectionLoading extends EpsConnectionState {
  const EpsConnectionLoading();
}

class EpsConnectionConnected extends EpsConnectionState {
  final String patientId;
  const EpsConnectionConnected(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class EpsConnectionDisconnected extends EpsConnectionState {
  const EpsConnectionDisconnected();
}

class EpsConnectionError extends EpsConnectionState {
  final String message;
  const EpsConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}
