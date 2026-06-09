/// Sync repository for IHCE Colombia
/// Uses FhirClient natively from Flutter - no backend needed
/// Communicates directly with IHCE FHIR APIs from the device
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/user_profile/domain/entities/user_profile.dart';
import '../../../features/medications/domain/entities/medication.dart' as app_med;
import '../../../features/allergies/domain/entities/allergy.dart';
import '../../../features/vitals/domain/entities/vital_sign.dart' as app_vital;
import 'package:medical_standards/medical_standards.dart';
import 'fhir_client.dart';
import 'fhir_mapper.dart';
import 'rda_parser.dart';
import 'node_discovery_service.dart';

@lazySingleton
class SyncRepository {
  final FhirClient _fhirClient;
  final Isar _isar;
  final FlutterSecureStorage _secureStorage;
  final NodeDiscoveryService _discoveryService;

  SyncRepository(
    this._fhirClient,
    this._isar,
    this._secureStorage,
    this._discoveryService,
  );

  static const String _lastSyncKey = 'last_fhir_sync_timestamp';

  /// Get access token from secure storage
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'ihce_access_token');
  }

  /// Save access token to secure storage
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: 'ihce_access_token', value: token);
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> _setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }

  /// Full sync: Patient profile + RDA (medications, allergies, vitals, conditions) + P2P Medical Standards
  Future<void> syncAll() async {
    // 0. Sync Medical Standards via P2P if possible
    await syncMedicalStandards();

    final token = await getAccessToken();
    if (token == null) {
      throw Exception('No hay conexión con IHCE. Conectá tu EPS primero.');
    }

    final profile = await _isar.userProfiles.where().findFirst();
    if (profile == null || profile.epsPatientId == null) {
      throw Exception('Perfil no encontrado o sin ID de paciente IHCE.');
    }

    final patientId = profile.epsPatientId!;

    // 1. Sync Patient -> UserProfile
    await _syncPatient(patientId, token, profile);

    // 2. Sync RDA
    await _syncRda(patientId, token);

    await _setLastSyncTime(DateTime.now());
  }

  Future<void> _syncPatient(
    String patientId,
    String token,
    UserProfile existingProfile,
  ) async {
    try {
      final patientData = await _fhirClient.getPatient(patientId, token);
      final updatedProfile = FhirMapper.mapPatient(patientData, existingProfile);

      await _isar.writeTxn(() async {
        await _isar.userProfiles.put(updatedProfile);
      });
    } catch (e) {
      print('Error syncing patient: $e');
    }
  }

  Future<void> _syncRda(String patientId, String token) async {
    try {
      final rdaBundle = await _fhirClient.getRDA(patientId, token);
      final parsed = RdaParser.parse(rdaBundle);
      if (parsed == null) return;

      final sections = parsed['sections'] as List<dynamic>? ?? [];
      final medications = <app_med.Medication>[];
      final allergies = <Allergy>[];
      final conditions = <String>[];
      final vitals = <app_vital.VitalSign>[];

      // Process each section - entries from IHCE RDA
      // In a real scenario, we'd also fetch the full Bundle resources
      // For now, search for resources referenced in the Composition
      for (final section in sections) {
        final sectionMap = section as Map<String, dynamic>;
        final entries = sectionMap['entries'] as List<dynamic>? ?? [];

        for (final entry in entries) {
          final resource = entry as Map<String, dynamic>?;
          if (resource == null) continue;

          final type = resource['resourceType'] as String?;
          switch (type) {
            case 'MedicationStatement':
            case 'MedicationRequest':
              final med = FhirMapper.mapMedicationStatement(resource);
              if (med != null) medications.add(med);
              break;
            case 'AllergyIntolerance':
              final allergy = FhirMapper.mapAllergyIntolerance(resource);
              if (allergy != null) allergies.add(allergy);
              break;
            case 'Condition':
              final code = FhirMapper.mapConditionCode(resource);
              if (code != null) conditions.add(code);
              break;
            case 'Observation':
              final obsVitals = FhirMapper.mapObservation(resource);
              vitals.addAll(obsVitals);
              break;
          }
        }
      }

      // Save all to Isar with deduplication
      await _isar.writeTxn(() async {
        if (medications.isNotEmpty) {
          for (final med in medications) {
            final existing = await _isar.medications
                .filter()
                .nameEqualTo(med.name)
                .startDateEqualTo(med.startDate)
                .findFirst();
            if (existing != null) {
              med.id = existing.id; // Update existing
            }
            await _isar.medications.put(med);
          }
        }
        if (allergies.isNotEmpty) {
          for (final allergy in allergies) {
            final existing = await _isar.allergys
                .filter()
                .allergenEqualTo(allergy.allergen)
                .findFirst();
            if (existing != null) {
              allergy.id = existing.id; // Update existing
            }
            await _isar.allergys.put(allergy);
          }
        }
        if (vitals.isNotEmpty) {
          for (final vital in vitals) {
            final existing = await _isar.vitalSigns
                .filter()
                .typeEqualTo(vital.type)
                .dateTimeEqualTo(vital.dateTime)
                .findFirst();
            if (existing != null) {
              // Only update if value is different or to ensure we have the latest
              vital.id = existing.id;
            }
            await _isar.vitalSigns.put(vital);
          }
        }
        if (conditions.isNotEmpty) {
          final profile = await _isar.userProfiles.where().findFirst();
          if (profile != null) {
            final existing = profile.medicalConditions;
            final updated = {...existing, ...conditions}.toList();
            await _isar.userProfiles.put(
              profile.copyWith(medicalConditions: updated),
            );
          }
        }
      });
    } catch (e) {
      print('Error syncing RDA: $e');
    }
  }

  /// Sync medical standards from peers if any are discovered
  Future<void> syncMedicalStandards() async {
    final peers = _discoveryService.currentNodes;
    final syncService = SyncService();

    if (peers.isNotEmpty) {
      // Try to sync from the first available peer
      final peer = peers.first;
      final peerIp = '${peer.host}:${peer.port}';
      await syncService.syncAll(peerIp: peerIp);
    } else {
      // Fallback to default (GitHub)
      await syncService.syncAll();
    }
  }

  /// Quick sync - only refresh if last sync was > 6 hours ago
  Future<bool> syncIfStale() async {
    final lastSync = await getLastSyncTime();
    if (lastSync != null) {
      final staleThreshold = DateTime.now().subtract(const Duration(hours: 6));
      if (lastSync.isAfter(staleThreshold)) {
        return false; // Not stale, skip
      }
    }
    await syncAll();
    return true; // Synced
  }
}
