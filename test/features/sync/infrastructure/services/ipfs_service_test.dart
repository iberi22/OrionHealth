import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto/crypto.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/ipfs_service.dart';
import 'package:orionhealth_health/features/sync/infrastructure/datasources/ipfs_datasource.dart';
import 'package:orionhealth_health/features/sync/infrastructure/datasources/filecoin_datasource.dart';

class MockIpfsDatasource extends Mock implements IpfsDatasource {}
class MockFilecoinDatasource extends Mock implements FilecoinDatasource {}

void main() {
  late IpfsService ipfsService;
  late MockIpfsDatasource mockIpfsDatasource;
  late MockFilecoinDatasource mockFilecoinDatasource;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockIpfsDatasource = MockIpfsDatasource();
    mockFilecoinDatasource = MockFilecoinDatasource();
    ipfsService = IpfsService(mockIpfsDatasource, mockFilecoinDatasource);
  });

  group('IpfsService', () {
    test('cacheData adds and pins data, return CID', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'Qm123';
      when(() => mockIpfsDatasource.add(data)).thenAnswer((_) async => cid);
      when(() => mockIpfsDatasource.pin(cid)).thenAnswer((_) async => {});

      final result = await ipfsService.cacheData(data);

      expect(result, cid);
      verify(() => mockIpfsDatasource.add(data)).called(1);
      verify(() => mockIpfsDatasource.pin(cid)).called(1);
      verifyNever(() => mockFilecoinDatasource.store(any()));
    });

    test('cacheData backs up to Filecoin when requested', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'Qm123';
      when(() => mockIpfsDatasource.add(data)).thenAnswer((_) async => cid);
      when(() => mockIpfsDatasource.pin(cid)).thenAnswer((_) async => {});
      when(() => mockFilecoinDatasource.store(data)).thenAnswer((_) async => 'deal-id');

      await ipfsService.cacheData(data, backupToFilecoin: true);

      verify(() => mockFilecoinDatasource.store(data)).called(1);
    });

    test('getData returns data when hash matches', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'Qm123';
      final expectedHash = sha256.convert(data).toString();

      when(() => mockIpfsDatasource.get(cid)).thenAnswer((_) async => data);

      final result = await ipfsService.getData(cid, expectedHash);

      expect(result, data);
    });

    test('getData throws Exception when hash mismatch', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'Qm123';
      const wrongHash = 'wrong-hash';

      when(() => mockIpfsDatasource.get(cid)).thenAnswer((_) async => data);

      expect(
        () => ipfsService.getData(cid, wrongHash),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('integrity verification failed'))),
      );
    });
  });
}
