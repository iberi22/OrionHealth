import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/datasources/license_registry_local.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/license_registry.dart';

class MockIsar extends Mock implements Isar {}

class MockLicenseRegistryLocalCollection extends Mock
    implements IsarCollection<LicenseRegistryLocal> {}

class MockLicenseRegistryLocalFilter extends Mock
    implements FilterQueryBuilder<LicenseRegistryLocal, LicenseRegistryLocal> {}

class MockLicenseRegistryLocalQuery extends Mock
    implements Future<LicenseRegistryLocal?> {}

void main() {
  late MockIsar mockIsar;
  late LicenseRegistryLocalDataSource dataSource;

  setUp(() {
    mockIsar = MockIsar();
    dataSource = LicenseRegistryLocalDataSource(mockIsar);
  });

  group('LicenseRegistryLocalDataSource', () {
    test('getHashesForCountry returns hashes when registry exists', () async {
      final registry = LicenseRegistryLocal(
        countryCode: 'US',
        hashes: ['abc123', 'def456'],
      );

      // Use the actual Isar collection API pattern
      // We mock the filter chain
      when(() => mockIsar.licenseRegistryLocals).thenReturn(
        _createMockCollectionWithFilter('US', registry),
      );

      final result = await dataSource.getHashesForCountry('US');

      expect(result, ['abc123', 'def456']);
    });

    test('getHashesForCountry returns empty list when registry not found', () async {
      when(() => mockIsar.licenseRegistryLocals).thenReturn(
        _createMockCollectionWithFilter('XX', null),
      );

      final result = await dataSource.getHashesForCountry('XX');

      expect(result, isEmpty);
    });
  });
}

IsarCollection<LicenseRegistryLocal> _createMockCollectionWithFilter(
  String countryCode,
  LicenseRegistryLocal? result,
) {
  final mockCollection = MockLicenseRegistryLocalCollection();
  final mockFilter = MockLicenseRegistryLocalFilter();
  final mockQuery = MockLicenseRegistryLocalQuery();

  when(() => mockCollection.filter()).thenReturn(mockFilter);
  when(() => mockFilter.countryCodeEqualTo(countryCode)).thenReturn(mockFilter);
  when(() => mockFilter.findFirst()).thenAnswer((_) async => result);

  return mockCollection;
}
