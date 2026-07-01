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

  group('DistributedStorageService (IpfsService)', () {
    test('cacheData stores data and returns CID', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'QmTest';

      when(() => mockIpfsDatasource.add(data)).thenAnswer((_) async => cid);
      when(() => mockIpfsDatasource.pin(cid)).thenAnswer((_) async => {});

      final result = await ipfsService.cacheData(data);

      expect(result, cid);
      verify(() => mockIpfsDatasource.add(data)).called(1);
      verify(() => mockIpfsDatasource.pin(cid)).called(1);
    });

    test('getData retrieves data and verifies hash', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'QmTest';
      final hash = sha256.convert(data).toString();

      when(() => mockIpfsDatasource.get(cid)).thenAnswer((_) async => data);

      final result = await ipfsService.getData(cid, hash);

      expect(result, data);
    });

    test('getData throws Exception on hash mismatch (Conflict/Integrity)', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'QmTest';
      const wrongHash = 'wronghash';

      when(() => mockIpfsDatasource.get(cid)).thenAnswer((_) async => data);

      expect(
        () => ipfsService.getData(cid, wrongHash),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('integrity verification failed'))),
      );
    });

    test('handles network/datasource errors', () async {
      final data = Uint8List.fromList([1, 2, 3]);

      when(() => mockIpfsDatasource.add(any())).thenThrow(Exception('Network unreachable'));

      expect(
        () => ipfsService.cacheData(data),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Network unreachable'))),
      );
    });

    test('cacheData with backupToFilecoin calls filecoin datasource', () async {
       final data = Uint8List.fromList([1, 2, 3]);
       const cid = 'QmTest';

       when(() => mockIpfsDatasource.add(data)).thenAnswer((_) async => cid);
       when(() => mockIpfsDatasource.pin(cid)).thenAnswer((_) async => {});
       when(() => mockFilecoinDatasource.store(data)).thenAnswer((_) async => 'deal-id');

       await ipfsService.cacheData(data, backupToFilecoin: true);

       verify(() => mockFilecoinDatasource.store(data)).called(1);
    });
  });
}
