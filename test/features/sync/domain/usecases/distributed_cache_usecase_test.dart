import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/usecases/distributed_cache_usecase.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/ipfs_service.dart';

class MockIpfsService extends Mock implements IpfsService {}

void main() {
  late DistributedCacheUsecase usecase;
  late MockIpfsService mockIpfsService;

  setUp(() {
    mockIpfsService = MockIpfsService();
    usecase = DistributedCacheUsecase(mockIpfsService);
  });

  final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
  const testCid = 'QmTest123';

  group('DistributedCacheUsecase', () {
    group('cacheStandard', () {
      test('should return CID when IPFS caching succeeds', () async {
        when(() => mockIpfsService.cacheData(testData))
            .thenAnswer((_) async => testCid);

        final result = await usecase.cacheStandard(testData);

        expect(result, testCid);
        verify(() => mockIpfsService.cacheData(testData)).called(1);
      });

      test('should return null when IPFS caching fails', () async {
        when(() => mockIpfsService.cacheData(testData))
            .thenThrow(Exception('IPFS unavailable'));

        final result = await usecase.cacheStandard(testData);

        expect(result, isNull);
        verify(() => mockIpfsService.cacheData(testData)).called(1);
      });
    });

    group('getStandard', () {
      const expectedHash = 'abc123hash';
      final fallbackData = Uint8List.fromList([10, 11, 12]);

      test('should return data from IPFS when retrieval succeeds', () async {
        when(() => mockIpfsService.getData(testCid, expectedHash))
            .thenAnswer((_) async => testData);

        final result = await usecase.getStandard(
          testCid,
          expectedHash,
          () async => fallbackData,
        );

        expect(result, testData);
        verify(() => mockIpfsService.getData(testCid, expectedHash)).called(1);
      });

      test('should return fallback data when IPFS retrieval fails', () async {
        when(() => mockIpfsService.getData(testCid, expectedHash))
            .thenThrow(Exception('IPFS retrieval failed'));

        final result = await usecase.getStandard(
          testCid,
          expectedHash,
          () async => fallbackData,
        );

        expect(result, fallbackData);
        verify(() => mockIpfsService.getData(testCid, expectedHash)).called(1);
      });

      test('should propagate fallback exceptions', () async {
        when(() => mockIpfsService.getData(testCid, expectedHash))
            .thenThrow(Exception('IPFS retrieval failed'));

        expect(
          () => usecase.getStandard(
            testCid,
            expectedHash,
            () async => throw Exception('Fallback also failed'),
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
