import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/domain/sync_service.dart';
import 'package:orionhealth_health/features/sync/domain/sync_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';

class MockSyncRepository extends Mock implements SyncRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late SyncService syncService;
  late MockSyncRepository mockSyncRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  setUp(() {
    mockSyncRepository = MockSyncRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    syncService = SyncService(mockSyncRepository, mockUserProfileRepository);

    // Default mock for getDiscoveredNodes to avoid TypeError
    when(() => mockSyncRepository.getDiscoveredNodes()).thenReturn([]);
  });

  group('SyncService', () {
    test('syncAll throws exception when no token', () async {
      when(() => mockSyncRepository.getAccessToken()).thenAnswer((_) async => null);

      expect(() => syncService.syncAll(), throwsException);
    });

    test('syncAll throws exception when no profile', () async {
      when(() => mockSyncRepository.getAccessToken()).thenAnswer((_) async => 'token');
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => null);

      expect(() => syncService.syncAll(), throwsException);
    });

    test('syncAll performs sync correctly when everything is set', () async {
      when(() => mockSyncRepository.getAccessToken()).thenAnswer((_) async => 'token');
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(epsPatientId: '123'));
      when(() => mockSyncRepository.syncPatient(any(), any())).thenAnswer((_) async => {});
      when(() => mockSyncRepository.syncRda(any(), any())).thenAnswer((_) async => {});
      when(() => mockSyncRepository.setLastSyncTime(any())).thenAnswer((_) async => {});

      await syncService.syncAll();

      verify(() => mockSyncRepository.syncPatient('123', 'token')).called(1);
      verify(() => mockSyncRepository.syncRda('123', 'token')).called(1);
      verify(() => mockSyncRepository.setLastSyncTime(any())).called(1);
    });

    test('syncIfStale does not sync if not stale', () async {
      final lastSync = DateTime.now().subtract(const Duration(hours: 1));
      when(() => mockSyncRepository.getLastSyncTime()).thenAnswer((_) async => lastSync);

      final result = await syncService.syncIfStale();

      expect(result, false);
      verifyNever(() => mockSyncRepository.syncPatient(any(), any()));
    });

    test('syncIfStale syncs if stale', () async {
      final lastSync = DateTime.now().subtract(const Duration(hours: 7));
      when(() => mockSyncRepository.getLastSyncTime()).thenAnswer((_) async => lastSync);
      when(() => mockSyncRepository.getAccessToken()).thenAnswer((_) async => 'token');
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(epsPatientId: '123'));
      when(() => mockSyncRepository.syncPatient(any(), any())).thenAnswer((_) async => {});
      when(() => mockSyncRepository.syncRda(any(), any())).thenAnswer((_) async => {});
      when(() => mockSyncRepository.setLastSyncTime(any())).thenAnswer((_) async => {});

      final result = await syncService.syncIfStale();

      expect(result, true);
      verify(() => mockSyncRepository.syncPatient('123', 'token')).called(1);
    });
  });
}
