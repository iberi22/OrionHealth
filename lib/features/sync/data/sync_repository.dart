import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/user_profile/domain/entities/user_profile.dart';
import '../../../features/medications/domain/entities/medication.dart';
import '../../../features/allergies/domain/entities/allergy.dart';
import '../../../features/vitals/domain/entities/vital_sign.dart';
import 'fhir_mapper.dart';

@lazySingleton
class SyncRepository {
  final Dio _dio;
  final Isar _isar;

  SyncRepository(this._dio, this._isar);

  static const String _baseUrl = 'https://ihce-api.example.com'; // Placeholder, would be configurable
  static const String _lastSyncKey = 'last_fhir_sync_timestamp';

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> _setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }

  Future<void> syncAll() async {
    final profile = await _isar.userProfiles.where().findFirst();
    if (profile == null || profile.uniqueId == null) {
      throw Exception('User profile not found or missing IHCE ID');
    }

    final patientId = profile.uniqueId!;

    // 1. Sync Patient -> UserProfile
    await _syncPatient(patientId, profile);

    // 2. Sync RDA (Medication, Allergy, Condition, Observation)
    await _syncRda(patientId);

    await _setLastSyncTime(DateTime.now());
  }

  Future<void> _syncPatient(String patientId, UserProfile existingProfile) async {
    try {
      final response = await _dio.get('$_baseUrl/api/fhir/patient/$patientId');
      if (response.statusCode == 200) {
        final patientData = response.data as Map<String, dynamic>;
        final updatedProfile = FhirMapper.mapPatient(patientData, existingProfile);

        await _isar.writeTxn(() async {
          await _isar.userProfiles.put(updatedProfile);
        });
      }
    } catch (e) {
      // Log or handle error
      print('Error syncing patient: $e');
    }
  }

  Future<void> _syncRda(String patientId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/fhir/rda', queryParameters: {'patient': patientId});
      if (response.statusCode == 200) {
        final bundle = response.data as Map<String, dynamic>;
        final entries = bundle['entry'] as List?;
        if (entries == null) return;

        final medications = <Medication>[];
        final allergies = <Allergy>[];
        final conditions = <String>[];
        final vitals = <VitalSign>[];

        for (final entry in entries) {
          final resource = entry['resource'] as Map<String, dynamic>?;
          if (resource == null) continue;

          final type = resource['resourceType'];
          switch (type) {
            case 'MedicationStatement':
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

        await _isar.writeTxn(() async {
          if (medications.isNotEmpty) {
            await _isar.medications.putAll(medications);
          }
          if (allergies.isNotEmpty) {
            await _isar.allergys.putAll(allergies);
          }
          if (vitals.isNotEmpty) {
            await _isar.vitalSigns.putAll(vitals);
          }
          if (conditions.isNotEmpty) {
            final profile = await _isar.userProfiles.where().findFirst();
            if (profile != null) {
              final updatedConditions = {...profile.medicalConditions, ...conditions}.toList();
              await _isar.userProfiles.put(profile.copyWith(medicalConditions: updatedConditions));
            }
          }
        });
      }
    } catch (e) {
      print('Error syncing RDA: $e');
    }
  }
}
