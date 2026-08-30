import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/data_export_repository.dart';

/// GDPR Art. 20 — Right to Data Portability
///
/// Generates a portable ZIP archive containing all user data in JSON format.
/// Pure Dart ZIP encoder (no external dependencies).
class DataExportService {
  final DataExportRepository _repository;
  final SecureStorageService _secureStorage;

  DataExportService(this._repository, this._secureStorage);

  /// Exports all user data into a ZIP file. Returns path to generated file.
  Future<File> exportUserData() async {
    final files = await _collectAllData();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final output = File('${dir.path}/orionhealth_export_$timestamp.zip');

    await output.writeAsBytes(_encodeZip(files));
    return output;
  }

  /// Returns summary of what will be exported (for UI confirmation).
  Future<ExportSummary> getExportSummary() async {
    final userId = await _getCurrentUserId();
    return ExportSummary(
      userProfile: await _repository.countUserProfiles(userId),
      medicalRecords: await _repository.countMedicalRecords(userId),
      medications: await _repository.countMedications(userId),
      allergies: await _repository.countAllergies(userId),
      appointments: await _repository.countAppointments(userId),
      vitalSigns: await _repository.countVitalSigns(userId),
      reports: await _repository.countReports(userId),
      doctorProfiles: await _repository.countDoctorProfiles(userId),
      appSettings: await _repository.countAppSettings(),
    );
  }

  Future<String> _getCurrentUserId() async {
    return await _secureStorage.read('user_id') ??
        await _secureStorage.read('profile_unique_id') ??
        'default_user';
  }

  Future<Map<String, String>> _collectAllData() async {
    final userId = await _getCurrentUserId();
    final files = <String, String>{};

    files['README.md'] = _readmeContent(userId);

    files['profile.json'] = _jsonEncode({
      'count': await _repository.countUserProfiles(userId),
      'data': await _repository.getUserProfiles(userId),
    });

    files['medical_records.json'] = _jsonEncode({
      'count': await _repository.countMedicalRecords(userId),
      'data': await _repository.getMedicalRecords(userId),
    });

    files['medications.json'] = _jsonEncode({
      'count': await _repository.countMedications(userId),
      'data': await _repository.getMedications(userId),
    });

    files['allergies.json'] = _jsonEncode({
      'count': await _repository.countAllergies(userId),
      'data': await _repository.getAllergies(userId),
    });

    files['appointments.json'] = _jsonEncode({
      'count': await _repository.countAppointments(userId),
      'data': await _repository.getAppointments(userId),
    });

    files['vitals.json'] = _jsonEncode({
      'count': await _repository.countVitalSigns(userId),
      'data': await _repository.getVitalSigns(userId),
    });

    files['reports.json'] = _jsonEncode({
      'count': await _repository.countReports(userId),
      'data': await _repository.getReports(userId),
    });

    files['doctor_profiles.json'] = _jsonEncode({
      'count': await _repository.countDoctorProfiles(userId),
      'data': await _repository.getDoctorProfiles(userId),
    });

    files['app_settings.json'] = _jsonEncode({
      'count': await _repository.countAppSettings(),
      'data': await _repository.getAppSettings(),
    });

    files['metadata.json'] = _jsonEncode({
      'export_timestamp': DateTime.now().toUtc().toIso8601String(),
      'user_id': userId,
      'app_version': '0.9.0+2',
      'gdpr_article': 'Art. 20 — Right to data portability',
      'format': 'JSON + ZIP (PKWARE spec)',
      'encryption': 'None (intentional — see privacy-policy.md)',
    });

    return files;
  }

  String _readmeContent(String userId) {
    return '''# OrionHealth Data Export

Generated: ${DateTime.now().toUtc().toIso8601String()}
User ID: $userId
App version: 0.9.0+2

## Contents

This ZIP contains all your personal data stored by OrionHealth:

| File | Description |
|------|-------------|
| `metadata.json` | Export metadata (timestamp, user_id, format info) |
| `profile.json` | Your user profile |
| `medical_records.json` | Medical history records |
| `medications.json` | Current and historical medications |
| `allergies.json` | Known allergies and adverse reactions |
| `appointments.json` | Scheduled and past appointments |
| `vitals.json` | Vital signs measurements |
| `reports.json` | Generated health reports |
| `doctor_profiles.json` | Verified doctor profiles you've saved |
| `app_settings.json` | App preferences and configuration |

## Your Rights

This export was generated in compliance with **GDPR Art. 20** (Right to
Data Portability) and **Ley 1581 de 2012 Art. 17** (Acceso).

You also have the right to:
- **Rectification**: correct inaccurate data
- **Cancellation/Erasure**: delete all or part of your data
- **Opposition**: object to specific processing

Visit Settings → My Rights in the OrionHealth app, or see
docs/privacy-policy.md for details.

## Security Notice

This ZIP is **NOT encrypted** because it is your personal data export
intended to be readable by you. Store it securely. Do not share it
without understanding the privacy implications.

Last reviewed: 2026-08-29 — Wave 9
''';
  }

  String _jsonEncode(Object data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  // ── ZIP encoder (pure Dart, PKWARE spec) ──────────────────────────────

  List<int> _encodeZip(Map<String, String> files) {
    final entries = <_ZipEntry>[];
    for (final entry in files.entries) {
      entries.add(_ZipEntry(
        filename: entry.key,
        content: Uint8List.fromList(utf8.encode(entry.value)),
      ));
    }

    final builder = BytesBuilder();
    int offset = 0;

    for (final entry in entries) {
      entry.localFileOffset = offset;
      builder.add(entry.localFileHeader);
      offset += entry.localFileHeader.length;
    }

    final centralDirStart = offset;
    for (final entry in entries) {
      builder.add(entry.centralDirectoryEntry);
      offset += entry.centralDirectoryEntry.length;
    }

    builder.add(_endOfCentralDirectory(
      entryCount: entries.length,
      cdSize: offset - centralDirStart,
      cdOffset: centralDirStart,
    ));

    return builder.toBytes();
  }
}

class _ZipEntry {
  final String filename;
  final Uint8List content;
  late int localFileOffset;
  late final Uint8List localFileHeader;
  late final Uint8List centralDirectoryEntry;

  _ZipEntry({required this.filename, required this.content}) {
    final nameBytes = utf8.encode(filename);
    final crc = _crc32(content);
    final size = content.length;
    final modTime = _dosTime(DateTime.now());

    final local = BytesBuilder()
      ..add([0x50, 0x4b, 0x03, 0x04])
      ..add([0x14, 0x00])
      ..add([0x00, 0x00])
      ..add([0x00, 0x00])
      ..add(_intToBytes(modTime, 2))
      ..add(_intToBytes(crc, 4))
      ..add(_intToBytes(size, 4))
      ..add(_intToBytes(size, 4))
      ..add(_intToBytes(nameBytes.length, 2))
      ..add(_intToBytes(0, 2))
      ..add(nameBytes)
      ..add(content);
    localFileHeader = local.toBytes();

    final cd = BytesBuilder()
      ..add([0x50, 0x4b, 0x01, 0x02])
      ..add([0x14, 0x00])
      ..add([0x14, 0x00])
      ..add([0x00, 0x00])
      ..add([0x00, 0x00])
      ..add(_intToBytes(modTime, 2))
      ..add(_intToBytes(crc, 4))
      ..add(_intToBytes(size, 4))
      ..add(_intToBytes(size, 4))
      ..add(_intToBytes(nameBytes.length, 2))
      ..add(_intToBytes(0, 2))
      ..add(_intToBytes(0, 2))
      ..add(_intToBytes(0, 2))
      ..add(_intToBytes(0, 2))
      ..add(_intToBytes(0, 0, 4))
      ..add(_intToBytes(localFileOffset, 4))
      ..add(nameBytes);
    centralDirectoryEntry = cd.toBytes();
  }
}

Uint8List _endOfCentralDirectory({
  required int entryCount,
  required int cdSize,
  required int cdOffset,
}) {
  return Uint8List.fromList([
    ...[0x50, 0x4b, 0x05, 0x06],
    ..._intToBytes(0, 2),
    ..._intToBytes(0, 2),
    ..._intToBytes(entryCount, 2),
    ..._intToBytes(entryCount, 2),
    ..._intToBytes(cdSize, 4),
    ..._intToBytes(cdOffset, 4),
    ..._intToBytes(0, 2),
  ]);
}

List<int> _intToBytes(int value, int bytes, [int? fixed]) {
  final result = <int>[];
  for (int i = 0; i < bytes; i++) {
    result.add((value >> (8 * i)) & 0xFF);
  }
  return result;
}

int _dosTime(DateTime dt) {
  return ((dt.hour & 0x1F) << 11) |
      ((dt.minute & 0x3F) << 5) |
      ((dt.second ~/ 2) & 0x1F);
}

int _crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (int i = 0; i < 8; i++) {
      crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

class ExportSummary {
  final int userProfile;
  final int medicalRecords;
  final int medications;
  final int allergies;
  final int appointments;
  final int vitalSigns;
  final int reports;
  final int doctorProfiles;
  final int appSettings;

  const ExportSummary({
    this.userProfile = 0,
    this.medicalRecords = 0,
    this.medications = 0,
    this.allergies = 0,
    this.appointments = 0,
    this.vitalSigns = 0,
    this.reports = 0,
    this.doctorProfiles = 0,
    this.appSettings = 0,
  });

  int get total => userProfile +
      medicalRecords +
      medications +
      allergies +
      appointments +
      vitalSigns +
      reports +
      doctorProfiles +
      appSettings;

  Map<String, dynamic> toJson() => {
        'user_profile': userProfile,
        'medical_records': medicalRecords,
        'medications': medications,
        'allergies': allergies,
        'appointments': appointments,
        'vital_signs': vitalSigns,
        'reports': reports,
        'doctor_profiles': doctorProfiles,
        'app_settings': appSettings,
        'total': total,
      };
}