import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:orionhealth_health/core/di/service_module.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

class TestServiceModule extends ServiceModule {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  group('ServiceModule DI', () {
    test('should register all services in GetIt', () {
      final gh = GetItHelper(getIt);
      final module = TestServiceModule();

      gh.lazySingleton<FlutterSecureStorage>(() => module.storage);
      gh.lazySingleton<FlutterAppAuth>(() => module.appAuth);
      gh.lazySingleton<http.Client>(() => module.httpClient);

      expect(getIt<FlutterSecureStorage>(), isA<FlutterSecureStorage>());
      expect(getIt<FlutterAppAuth>(), isA<FlutterAppAuth>());
      expect(getIt<http.Client>(), isA<http.Client>());
    });

    test('should register services as singletons', () {
      final gh = GetItHelper(getIt);
      final module = TestServiceModule();

      gh.lazySingleton<FlutterSecureStorage>(() => module.storage);
      gh.lazySingleton<http.Client>(() => module.httpClient);

      final storage1 = getIt<FlutterSecureStorage>();
      final storage2 = getIt<FlutterSecureStorage>();
      expect(storage1, same(storage2));

      final client1 = getIt<http.Client>();
      final client2 = getIt<http.Client>();
      expect(client1, same(client2));
    });
  });
}
