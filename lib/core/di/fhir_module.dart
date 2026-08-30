/// DI Module for FHIR native services (legacy IHCE — disabled in Wave 12).
/// The IHCE FHIR native services are not registered here anymore.
/// Kept as a structural placeholder for future generic FHIR adapters.
library;

import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import '../../features/sync/infrastructure/services/fhir_client.dart';

@module
abstract class FhirModule {
  @lazySingleton
  FhirClient get fhirClient => FhirClient(client: http.Client());
}
