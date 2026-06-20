import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/services/sync_service.dart';

class MockSyncService extends Mock implements SyncService {}

void main() {
  group('SyncService Interface', () {
    late MockSyncService mockSyncService;

    setUp(() {
      mockSyncService = MockSyncService();
    });

    test('performFullSync signature verification', () async {
      when(() => mockSyncService.performFullSync()).thenAnswer((_) async => {});
      await mockSyncService.performFullSync();
      verify(() => mockSyncService.performFullSync()).called(1);
    });

    test('getLastSyncTime signature verification', () async {
      final now = DateTime.now();
      when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => now);
      final result = await mockSyncService.getLastSyncTime();
      expect(result, now);
    });
  });
}
