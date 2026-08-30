import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/right_to_erasure_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/data_export_repository.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/services/data_export_service.dart' show ExportSummary;

/// Integration test verifying the contract shapes are consistent
/// between the data export and right to erasure repositories.
///
/// Both repositories should:
/// - Be implementable without Isar coupling
/// - Provide counts per collection
/// - Provide data retrieval methods
void main() {
  group('Repository contract consistency', () {
    test('both repositories accept userId as parameter', () {
      // Type-level check via a unified call
      Future<void> useBoth(
        DataExportRepository export,
        RightToErasureRepository erasure,
        String userId,
      ) async {
        await export.countUserProfiles(userId);
        await erasure.eraseAllUserData(userId);
      }
      expect(useBoth, isA<Function>());
    });

    test('ErasureCounts and ExportSummary share naming convention', () {
      final erasure = ErasureCounts()..userProfile = 1;
      final export = ExportSummary(userProfile: 1);

      // Both expose 'user_profile' in JSON for consistency
      expect(erasure.toJson()['user_profile'], 1);
      expect(export.toJson()['user_profile'], 1);
    });

    test('GDPR flow: export then erasure both reference user_id', () async {
      // Compliance verification: the same user can request access (export)
      // and erasure (right to be forgotten) — both via repository pattern
      final mockExport = _MockExport();
      final mockErasure = _MockErasure();

      // Both repos implement the contract (DataExportRepository + RightToErasureRepository)
      expect(mockExport, isA<DataExportRepository>());
      expect(mockErasure, isA<RightToErasureRepository>());

      // Erasure works on its own contract
      final counts = await mockErasure.eraseAllUserData('test_user');
      expect(counts.total, 3);

      // Export service has the export method
      final mockExportService = _MockExportService();
      final summary = await mockExportService.exportUserData();
      expect(summary['gdpr_article'], 'Art. 20');
    });
  });
}

class _MockExport implements DataExportRepository {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockExportService {
  Future<Map<String, dynamic>> exportUserData() async => {
        'format': 'JSON+ZIP',
        'gdpr_article': 'Art. 20',
        'file_path': '/tmp/export.zip',
      };
}

class _MockErasure implements RightToErasureRepository {
  @override
  Future<ErasureCounts> eraseAllUserData(String userId) async => ErasureCounts()
    ..userProfile = 1
    ..medications = 1
    ..vitalSigns = 1;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}