import 'package:equatable/equatable.dart';
import 'eps_provider.dart';
import 'oauth_token.dart';

class EPSConnection extends Equatable {
  final EPSProvider provider;
  final OAuthToken token;
  final String patientId;
  final DateTime connectedAt;

  const EPSConnection({
    required this.provider,
    required this.token,
    required this.patientId,
    required this.connectedAt,
  });

  @override
  List<Object?> get props => [provider, token, patientId, connectedAt];
}
