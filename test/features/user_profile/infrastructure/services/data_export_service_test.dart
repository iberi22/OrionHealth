import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/services/secure_storage_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/data_export_repository.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/services/data_export_service.dart';

class _MockRepo implements DataExportRepository {
  final List<Map<String, dynamic>> _profiles = [
    {
      'id': 1,
      'name': 'Test User',
      'age': 30,
      'uniqueId': 'test_user',
    }
  ];
  final List<Map<String, dynamic>> _meds = [
    {'id': 1, 'name': 'Aspirin', 'dosage': '100mg'}
  ];
  final List<Map<String, dynamic>> _vitals = [
    {
      'id': 1,
      'heartRate': 72,
      'systolicBP': 120,
      'diastolicBP': 80,
      'timestamp': '2026-08-29T10:00:00Z'
    }
  ];

  @override
  Future<int> countUserProfiles(String userId) async => _profiles.length;
  @override
  Future<List<Map<String, dynamic>>> getUserProfiles(String userId) async =>
      _profiles;
  @override
  Future<int> countMedicalRecords(String userId) async => 0;
  @override
  Future<List<Map<String, dynamic>>> getMedicalRecords(String userId) async => [];
  @override
  Future<int> countMedications(String userId) async => _meds.length;
  @override
  Future<List<Map<String, dynamic>>> getMedications(String userId) async => _meds;
  @override
  Future<int> countAllergies(String userId) async => 0;
  @override
  Future<List<Map<String, dynamic>>> getAllergies(String userId) async => [];
  @override
  Future<int> countAppointments(String userId) async => 0;
  @override
  Future<List<Map<String, dynamic>>> getAppointments(String userId) async => [];
  @override
  Future<int> countVitalSigns(String userId) async => _vitals.length;
  @override
  Future<List<Map<String, dynamic>>> getVitalSigns(String userId) async => _vitals;
  @override
  Future<int> countReports(String userId) async => 0;
  @override
  Future<List<Map<String, dynamic>>> getReports(String userId) async => [];
  @override
  Future<int> countDoctorProfiles(String userId) async => 0;
  @override
  Future<List<Map<String, dynamic>>> getDoctorProfiles(String userId) async => [];
  @override
  Future<int> countAppSettings() async => 0;
  @override
  Future<List<Map<String, dynamic>>> getAppSettings() async => [];
}

void main() {
  group('DataExportService', () {
    late DataExportService service;

    setUp(() {
      service = DataExportService(_MockRepo(), _MockSecureStorage());
    });

    test('exportUserData creates a valid ZIP file', () async {
      final file = await service.exportUserData();

      expect(file, isA<File>());
      expect(await file.exists(), true);
      expect(await file.length(), greaterThan(0));

      // Validate ZIP signature
      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(4));
      expect(bytes[0], 0x50); // 'P'
      expect(bytes[1], 0x4B); // 'K'

      await file.delete();
    });

    test('exportSummary returns counts for all collections', () async {
      final summary = await service.getExportSummary();

      expect(summary.userProfile, 1);
      expect(summary.medications, 1);
      expect(summary.vitalSigns, 1);
      expect(summary.medicalRecords, 0);
      expect(summary.total, greaterThan(0));
    });

    test('ZIP contains README and JSON files', () async {
      final file = await service.exportUserData();
      final bytes = await file.readAsBytes();

      // Find End of Central Directory signature (0x06054b50 reversed)
      final eocdSig = <int>[0x50, 0x4B, 0x05, 0x06];
      final sigIndex = _indexOf(bytes, eocdSig);
      expect(sigIndex, greaterThanOrEqualTo(0),
          reason: 'ZIP should have End of Central Directory signature');

      // Parse entry count from EOCD record
      final entryCount =
          (bytes[sigIndex + 10]) | (bytes[sigIndex + 11] << 8);
      expect(entryCount, greaterThanOrEqualTo(10),
          reason: 'ZIP should contain 10+ entries (README + 9 JSONs + metadata)');

      await file.delete();
    });
  });
}

int _indexOf(List<int> haystack, List<int> needle) {
  for (int i = 0; i <= haystack.length - needle.length; i++) {
    bool match = true;
    for (int j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}

// Minimal SecureStorage mock
class _MockSecureStorage implements SecureStorageService {
  @override
  Future<String?> read(String key) async {
    if (key == 'user_id' || key == 'profile_unique_id') return 'test_user';
    return null;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}