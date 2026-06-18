import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/datasources/license_registry_local.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/license_registry.dart';
import 'package:path/path.dart' as p;

void main() {
  late Isar isar;
  late LicenseRegistryLocalDataSource dataSource;
  late String testDir;

  setUpAll(() async {
    testDir = p.join(Directory.current.path, 'test_db_license_registry');
    await Directory(testDir).create(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [LicenseRegistryLocalSchema],
      directory: testDir,
    );
    dataSource = LicenseRegistryLocalDataSource(isar);
  });

  tearDownAll(() async {
    await isar.close();
    if (await Directory(testDir).exists()) {
      await Directory(testDir).delete(recursive: true);
    }
  });

  setUp(() async {
    // Seed the database with test data
    await isar.writeTxn(() async {
      await isar.licenseRegistryLocals.clear();
      final usRegistry = LicenseRegistryLocal(
        countryCode: 'US',
        hashes: [
          'abc123',
          'def456',
        ],
      );
      await isar.licenseRegistryLocals.put(usRegistry);
    });
  });

  group('LicenseRegistryLocalDataSource', () {
    test('getHashesForCountry returns hashes for existing country', () async {
      final result = await dataSource.getHashesForCountry('US');

      expect(result, hasLength(2));
      expect(result, contains('abc123'));
      expect(result, contains('def456'));
    });

    test('getHashesForCountry returns empty list for unknown country', () async {
      final result = await dataSource.getHashesForCountry('XX');

      expect(result, isEmpty);
    });

    test('getHashesForCountry returns empty list for empty country code', () async {
      final result = await dataSource.getHashesForCountry('');

      expect(result, isEmpty);
    });

    test('multiple countries return correct hashes', () async {
      await isar.writeTxn(() async {
        final coRegistry = LicenseRegistryLocal(
          countryCode: 'CO',
          hashes: ['xyz789'],
        );
        await isar.licenseRegistryLocals.put(coRegistry);
      });

      final usResult = await dataSource.getHashesForCountry('US');
      final coResult = await dataSource.getHashesForCountry('CO');

      expect(usResult, contains('abc123'));
      expect(coResult, contains('xyz789'));
    });
  });
}
