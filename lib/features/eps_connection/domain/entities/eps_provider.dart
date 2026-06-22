import 'package:equatable/equatable.dart';

enum EPSProviderType { ihce, openmrs, fhir }

class EPSProvider extends Equatable {
  final String id;
  final String name;
  final String discoveryUrl;
  final String? revocationUrl;
  final String clientId;
  final String redirectUrl;
  final List<String> scopes;
  final EPSProviderType type;

  const EPSProvider({
    required this.id,
    required this.name,
    required this.discoveryUrl,
    this.revocationUrl,
    required this.clientId,
    required this.redirectUrl,
    required this.scopes,
    this.type = EPSProviderType.fhir,
  });

  @override
  List<Object?> get props => [id, name, discoveryUrl, revocationUrl, clientId, redirectUrl, scopes, type];
}
