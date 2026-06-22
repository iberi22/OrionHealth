/// DI Module for IHCE FHIR native services
library;

import 'package:injectable/injectable.dart';
import '../../features/sync/infrastructure/services/fhir_client.dart';
import 'package:http/http.dart' as http;

@module
abstract class FhirModule {
  @lazySingleton
  FhirClient fhirClient(http.Client httpClient) => FhirClient(client: httpClient);
}
