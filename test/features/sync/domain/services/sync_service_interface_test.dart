import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/services/sync_service.dart';

class MockSyncService extends Mock implements SyncService {}

void main() {
  late MockSyncService mockSyncService;

  setUp(() {
    mockSyncService = MockSyncService();
  });

  group('SyncService interface', () {
    test('performFullSync performs sync', () async {
      when(() => mockSyncService.performFullSync()).thenAnswer((_) async => {});
      await mockSyncService.performFullSync();
      verify(() => mockSyncService.performFullSync()).called(1);
    });

    test('getLastSyncTime returns time', () async {
      final now = DateTime.now();
      when(() => mockSyncService.getLastSyncTime()).thenAnswer((_) async => now);
      final result = await mockSyncService.getLastSyncTime();
      expect(result, now);
    });
  });
}
