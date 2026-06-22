import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' hide test;
import 'package:orionhealth_health/core/di/database_module.dart';
import 'package:health_wallet/health_wallet.dart' as wallet;
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';

class TestDatabaseModule extends DatabaseModule {
  @override
  Future<Isar> get isar async => MockIsar();
}
class MockIsar extends Mock implements Isar {}

void main() {
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
  });

  group('DatabaseModule DI', () {
    test('should register all services in GetIt', () async {
      final gh = GetItHelper(getIt);
      final module = TestDatabaseModule();

      await gh.factoryAsync<Isar>(() => module.isar, preResolve: true);
      gh.lazySingleton<wallet.EncryptionService>(() => module.walletEncryptionService);
      gh.lazySingleton<wallet.WalletService>(() => module.walletService(getIt<Isar>(), getIt<wallet.EncryptionService>()));

      expect(getIt<Isar>(), isA<Isar>());
      expect(getIt<wallet.EncryptionService>(), isA<wallet.EncryptionService>());
      expect(getIt<wallet.WalletService>(), isA<wallet.WalletService>());
    });

    test('should register services with correct status', () async {
      final gh = GetItHelper(getIt);
      final module = TestDatabaseModule();

      await gh.factoryAsync<Isar>(() => module.isar, preResolve: true);
      gh.lazySingleton<wallet.EncryptionService>(() => module.walletEncryptionService);
      gh.lazySingleton<wallet.WalletService>(() => module.walletService(getIt<Isar>(), getIt<wallet.EncryptionService>()));

      // Isar is factory in this registration, but usually it acts as a singleton if it's pre-resolved and held.
      // Wallet service is lazySingleton.

      final wallet1 = getIt<wallet.WalletService>();
      final wallet2 = getIt<wallet.WalletService>();
      expect(wallet1, same(wallet2));
    });
  });
}
