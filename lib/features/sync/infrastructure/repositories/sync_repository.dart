/// Sync repository for IHCE Colombia
/// Uses FhirClient natively from Flutter - no backend needed
/// Communicates directly with IHCE FHIR APIs from the device
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/sync_node.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../medications/domain/entities/medication.dart' as app_med;
import '../../../allergies/domain/entities/allergy.dart';
import '../../../vitals/domain/entities/vital_sign.dart' as app_vital;
import '../services/fhir_client.dart';
import '../services/fhir_mapper.dart';
import '../services/rda_parser.dart';
import '../services/node_discovery_service.dart';

@LazySingleton(as: SyncRepository)
class SyncRepositoryImpl implements SyncRepository {
  final FhirClient _fhirClient;
  final Isar _isar;
  final FlutterSecureStorage _secureStorage;
  final NodeDiscoveryService _discoveryService;

  SyncRepositoryImpl(
    this._fhirClient,
    this._isar,
    this._secureStorage,
    this._discoveryService,
  );

  static const String _lastSyncKey = 'last_fhir_sync_timestamp';

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'ihce_access_token');
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: 'ihce_access_token', value: token);
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }

  @override
  Future<void> syncPatient(
    String patientId,
    String token,
  ) async {
    final existingProfile = await _isar.userProfiles.where().findFirst();
    if (existingProfile == null) return;

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

  @override
  Future<void> syncRda(String patientId, String token) async {
    try {
      final rdaBundle = await _fhirClient.getRDA(patientId, token);
      final parsed = RdaParser.parse(rdaBundle);
      if (parsed == null) return;

      final sections = parsed['sections'] as List<dynamic>? ?? [];
      final medications = <app_med.Medication>[];
      final allergies = <Allergy>[];
      final conditions = <String>[];
      final vitals = <app_vital.VitalSign>[];

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

  @override
  Future<List<SyncNode>> getDiscoveredNodes() async {
    return _discoveryService.currentNodes.map((node) => SyncNode(
      id: node.attributes['nodeId'] ?? node.name,
      name: node.name,
      host: node.hostname ?? 'unknown',
      port: node.port,
    )).toList();
  }

  @override
  Future<bool> syncIfStale() async {
    final lastSync = await getLastSyncTime();
    if (lastSync != null) {
      final sixHoursAgo = DateTime.now().subtract(const Duration(hours: 6));
      if (lastSync.isAfter(sixHoursAgo)) {
        return false; // Not stale, skip
      }
    }
    await syncAll();
    return true;
  }

  @override
  Future<void> syncAll() async {
    // Full sync: read tokens and run all sync operations
    final token = await getAccessToken();
    if (token == null) return;
    // Get patient ID from user profile
    final profile = await _isar.userProfiles.where().findFirst();
    final patientId = profile?.epsPatientId ?? profile?.uniqueId ?? '';
    if (patientId.isEmpty) return;
    await syncPatient(patientId, token);
    await syncRda(patientId, token);
  }
}
