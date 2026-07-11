import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:orionhealth_health/core/di/service_module.dart';
import 'package:orionhealth_health/core/services/device_capability_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class TestServiceModule extends ServiceModule {}

class MockDeviceCapabilityService extends Mock
    implements DeviceCapabilityService {}

void main() {
  final getIt = GetIt.instance;
  late MockDeviceCapabilityService mockCapabilityService;

  setUp(() async {
    await getIt.reset();
    mockCapabilityService = MockDeviceCapabilityService();
    when(() => mockCapabilityService.isEmulator()).thenAnswer((_) async => false);
  });

  group('ServiceModule DI', () {
    test('should register all services in GetIt', () async {
      final gh = GetItHelper(getIt);
      final module = TestServiceModule();

      gh.lazySingletonAsync<FlutterSecureStorage>(
          () => module.storage(mockCapabilityService));
      gh.lazySingleton<FlutterAppAuth>(() => module.appAuth);
      gh.lazySingleton<http.Client>(() => module.httpClient);

      final storage = await getIt.getAsync<FlutterSecureStorage>();
      expect(storage, isA<FlutterSecureStorage>());
      expect(getIt<FlutterAppAuth>(), isA<FlutterAppAuth>());
      expect(getIt<http.Client>(), isA<http.Client>());
    });

    test('should register services as singletons', () async {
      final gh = GetItHelper(getIt);
      final module = TestServiceModule();

      gh.lazySingletonAsync<FlutterSecureStorage>(
          () => module.storage(mockCapabilityService));
      gh.lazySingleton<http.Client>(() => module.httpClient);

      final storage1 = await getIt.getAsync<FlutterSecureStorage>();
      final storage2 = await getIt.getAsync<FlutterSecureStorage>();
      expect(storage1, same(storage2));

      final client1 = getIt<http.Client>();
      final client2 = getIt<http.Client>();
      expect(client1, same(client2));
    });
  });
}
