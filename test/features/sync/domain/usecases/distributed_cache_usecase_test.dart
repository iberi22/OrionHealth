import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/services/distributed_storage_service.dart';
import 'package:orionhealth_health/features/sync/domain/usecases/distributed_cache_usecase.dart';

class MockDistributedStorageService extends Mock implements DistributedStorageService {}

void main() {
  late DistributedCacheUsecase usecase;
  late MockDistributedStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockDistributedStorageService();
    usecase = DistributedCacheUsecase(mockStorageService);
  });

  group('cacheStandard', () {
    test('returns CID on success', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'QmTest';
      when(() => mockStorageService.cacheData(data)).thenAnswer((_) async => cid);

      final result = await usecase.cacheStandard(data);

      expect(result, cid);
      verify(() => mockStorageService.cacheData(data)).called(1);
    });

    test('returns null on failure', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      when(() => mockStorageService.cacheData(data)).thenThrow(Exception('Storage error'));

      final result = await usecase.cacheStandard(data);

      expect(result, isNull);
    });
  });

  group('getStandard', () {
    test('returns data from storage on success', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      const cid = 'QmTest';
      const hash = 'hash';
      when(() => mockStorageService.getData(cid, hash)).thenAnswer((_) async => data);

      final result = await usecase.getStandard(cid, hash, () async => Uint8List(0));

      expect(result, data);
      verify(() => mockStorageService.getData(cid, hash)).called(1);
    });

    test('returns fallback data on storage failure', () async {
      final fallbackData = Uint8List.fromList([4, 5, 6]);
      const cid = 'QmTest';
      const hash = 'hash';
      when(() => mockStorageService.getData(cid, hash)).thenThrow(Exception('Storage error'));

      final result = await usecase.getStandard(cid, hash, () async => fallbackData);

      expect(result, fallbackData);
    });
  });
}
