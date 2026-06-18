import 'package:equatable/equatable.dart';
import '../../domain/entities/eps_connection.dart';

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

class EpsConnectionLoaded extends EpsConnectionState {
  final List<EPSConnection> connections;
  const EpsConnectionLoaded(this.connections);

  @override
  List<Object?> get props => [connections];
}

class EpsConnectionError extends EpsConnectionState {
  final String message;
  const EpsConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}
