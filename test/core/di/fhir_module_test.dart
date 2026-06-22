import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:orionhealth_health/core/di/fhir_module.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_client.dart';

class TestFhirModule extends FhirModule {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  group('FhirModule DI', () {
    test('should register all services in GetIt', () {
      final gh = GetItHelper(getIt);
      final module = TestFhirModule();

      gh.lazySingleton<FhirClient>(() => module.fhirClient);

      expect(getIt<FhirClient>(), isA<FhirClient>());
    });

    test('should register services as singletons', () {
      final gh = GetItHelper(getIt);
      final module = TestFhirModule();

      gh.lazySingleton<FhirClient>(() => module.fhirClient);

      final client1 = getIt<FhirClient>();
      final client2 = getIt<FhirClient>();
      expect(client1, same(client2));
    });
  });
}
