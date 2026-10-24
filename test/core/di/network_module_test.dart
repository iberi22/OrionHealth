import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:orionhealth_health/core/di/network_module.dart';
import 'package:dio/dio.dart';
import 'package:medical_standards/medical_standards.dart';

class TestNetworkModule extends NetworkModule {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  group('NetworkModule DI', () {
    test('should register all services in GetIt', () {
      final gh = GetItHelper(getIt);
      final module = TestNetworkModule();

      gh.lazySingleton<Dio>(() => module.dio);
      gh.lazySingleton<MedicalContextProvider>(() => module.medicalContextProvider);
      gh.lazySingleton<SyncService>(() => module.syncService);

      expect(getIt<Dio>(), isA<Dio>());
      expect(getIt<MedicalContextProvider>(), isA<MedicalContextProvider>());
      expect(getIt<SyncService>(), isA<SyncService>());
    });

    test('should register services as singletons', () {
      final gh = GetItHelper(getIt);
      final module = TestNetworkModule();

      gh.lazySingleton<Dio>(() => module.dio);
      gh.lazySingleton<SyncService>(() => module.syncService);

      final dio1 = getIt<Dio>();
      final dio2 = getIt<Dio>();
      expect(dio1, same(dio2));

      final sync1 = getIt<SyncService>();
      final sync2 = getIt<SyncService>();
      expect(sync1, same(sync2));
    });
  });
}
