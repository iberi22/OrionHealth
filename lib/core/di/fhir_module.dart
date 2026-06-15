/// DI Module for IHCE FHIR native services
library;

import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import '../../features/sync/infrastructure/services/fhir_client.dart';

@module
abstract class FhirModule {
  @lazySingleton
  http.Client get httpClient => http.Client();

  @lazySingleton
  FhirClient get fhirClient => FhirClient(client: httpClient);
}
