import 'package:equatable/equatable.dart';
import '../../domain/entities/eps_connection.dart';
import '../../domain/entities/eps_provider.dart';

sealed class EpsConnectionState extends Equatable {
  const EpsConnectionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial con el catálogo de EPS disponibles.
class EpsConnectionCatalog extends EpsConnectionState {
  final List<EPSProvider> availableProviders;
  final List<EPSConnection> connections;
  final List<String> connectedProviderIds;

  const EpsConnectionCatalog({
    required this.availableProviders,
    this.connections = const [],
    this.connectedProviderIds = const [],
  });

  @override
  List<Object?> get props => [
        availableProviders,
        connections,
        connectedProviderIds,
      ];
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

class EpsConnectionConnecting extends EpsConnectionState {
  final EPSProvider provider;
  const EpsConnectionConnecting(this.provider);

  @override
  List<Object?> get props => [provider];
}

class EpsConnectionError extends EpsConnectionState {
  final String message;
  const EpsConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful Patient Portal Extraction flow.
/// The patient authenticated through the EPS web portal (on-device RPA)
/// rather than through SMART on FHIR OAuth2.
class EpsConnectionPortalConnected extends EpsConnectionState {
  final EPSProvider provider;
  final String? patientId;

  const EpsConnectionPortalConnected({
    required this.provider,
    this.patientId,
  });

  @override
  List<Object?> get props => [provider, patientId];
}
