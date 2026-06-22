import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/utils/connectivity_manager.dart';
import 'package:orionhealth_health/features/sync/domain/services/sync_service.dart';

class MockConnectivity extends Mock implements Connectivity {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  late MockSyncService mockSyncService;
  late GetIt getIt;

  setUpAll(() {
    getIt = GetIt.instance;
  });

  setUp(() {
    mockSyncService = MockSyncService();
    if (getIt.isRegistered<SyncService>()) {
      getIt.unregister<SyncService>();
    }
    getIt.registerSingleton<SyncService>(mockSyncService);

    when(() => mockSyncService.performFullSync()).thenAnswer((_) async {});
  });

  group('ConnectivityManager', () {
    test('initializes correctly', () async {
      final manager = ConnectivityManager();
      await manager.initialize();
      expect(manager.currentStatus, isNotNull);
    });

    test('requiresInternet returns true for specific operations', () {
      final manager = ConnectivityManager();
      expect(manager.requiresInternet('ai_chat'), isTrue);
      expect(manager.requiresInternet('unknown_op'), isFalse);
    });

    test('getStatusDescription returns correct string', () {
      final manager = ConnectivityManager();
      final description = manager.getStatusDescription();
      expect(
        description,
        anyOf([
          'Conectado a internet',
          'Sin conexión a internet',
          'Estado de conexión desconocido',
        ]),
      );
    });

    test('triggerDataSync calls SyncService.performFullSync', () async {
      final manager = ConnectivityManager();
      manager.triggerDataSync();

      // Since it's an unawaited call internally, we might need a small delay
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockSyncService.performFullSync()).called(1);
    });
  });
}
