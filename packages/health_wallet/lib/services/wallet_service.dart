import 'package:isar/isar.dart';
import '../models/health_record.dart';
import '../models/lab_result.dart';
import '../models/vital_sign.dart';
import '../models/medication_entry.dart';
import '../models/medical_document.dart';
import '../models/medical_event.dart';
import 'encryption_service.dart';

/// Sync status for records
enum SyncStatus {
  synced,
  pendingSync,
  conflict,
  error,
}

/// Source of medical data
enum DataSource {
  manual,       // User entered manually
  external,     // Received from another Orion node
  device,       // From connected device/wearable
  laboratory,   // From lab interface
  hospital,     // From hospital/health system
}

/// Main service for managing the health wallet
class WalletService {
  final Isar _isar;
  final EncryptionService _encryption;

  WalletService(this._isar, this._encryption);

  // ============ Labs ============

  Future<void> addLabResult(LabResult lab) async {
    await _isar.writeTxn(() async {
      await _isar.labResults.put(lab);
    });
  }

  Future<List<LabResult>> getLabsByLoinc(String loincCode) async {
    return await _isar.labResults
        .filter()
        .loincCodeEqualTo(loincCode)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<LabResult>> getRecentLabs({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return await _isar.labResults
        .filter()
        .dateGreaterThan(cutoff)
        .sortByDateDesc()
        .findAll();
  }

  // ============ Vitals ============

  Future<void> addVitalSign(VitalSign vital) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vital);
    });
  }

  Future<List<VitalSign>> getVitalsByType(String vitalType) async {
    return await _isar.vitalSigns
        .filter()
        .typeEqualTo(vitalType)
        .sortByTimestampDesc()
        .findAll();
  }

  Future<List<VitalSign>> getVitalsRange({
    required String vitalType,
    required DateTime from,
    required DateTime to,
  }) async {
    return await _isar.vitalSigns
        .filter()
        .typeEqualTo(vitalType)
        .timestampBetween(from, to)
        .sortByTimestamp()
        .findAll();
  }

  // ============ Medications ============

  Future<void> addMedication(MedicationEntry med) async {
    await _isar.writeTxn(() async {
      await _isar.medicationEntries.put(med);
    });
  }

  Future<List<MedicationEntry>> getActiveMedications() async {
    return await _isar.medicationEntries
        .filter()
        .endDateIsNull()
        .sortByName()
        .findAll();
  }

  Future<List<MedicationEntry>> getMedicationsByClass(String drugClass) async {
    return await _isar.medicationEntries
        .filter()
        .drugClassContains(drugClass)
        .findAll();
  }

  // ============ Medical Events ============

  Future<void> addMedicalEvent(MedicalEvent event) async {
    await _isar.writeTxn(() async {
      await _isar.medicalEvents.put(event);
    });
  }

  Future<List<MedicalEvent>> getEventsByType(String eventType) async {
    return await _isar.medicalEvents
        .filter()
        .typeEqualTo(eventType)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<MedicalEvent>> getTimeline({
    DateTime? from,
    DateTime? to,
  }) async {
    var query = _isar.medicalEvents.where();
    
    if (from != null && to != null) {
      return await query
          .filter()
          .dateBetween(from, to)
          .sortByDateDesc()
          .findAll();
    }
    
    return await query.sortByDateDesc().findAll();
  }

  // ============ Documents ============

  Future<void> addDocument(MedicalDocument doc) async {
    // Encrypt sensitive document data before storing
    final encrypted = await _encryption.encryptDocument(doc);
    await _isar.writeTxn(() async {
      await _isar.medicalDocuments.put(encrypted);
    });
  }

  Future<List<MedicalDocument>> getDocumentsByType(String docType) async {
    return await _isar.medicalDocuments
        .filter()
        .typeEqualTo(docType)
        .sortByDateDesc()
        .findAll();
  }

  // ============ Full Health Record ============

  Future<HealthRecord?> getFullHealthRecord() async {
    final records = await _isar.healthRecords.where().findAll();
    return records.isEmpty ? null : records.first;
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.healthRecords.put(record);
    });
  }

  // ============ Statistics ============

  Future<Map<String, int>> getDataStatistics() async {
    return {
      'labs': await _isar.labResults.count(),
      'vitals': await _isar.vitalSigns.count(),
      'medications': await _isar.medicationEntries.count(),
      'events': await _isar.medicalEvents.count(),
      'documents': await _isar.medicalDocuments.count(),
    };
  }

  // ============ Export/Import ============

  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'labs': await _isar.labResults.where().findAll(),
      'vitals': await _isar.vitalSigns.where().findAll(),
      'medications': await _isar.medicationEntries.where().findAll(),
      'events': await _isar.medicalEvents.where().findAll(),
      'documents': await _isar.medicalDocuments.where().findAll(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _isar.writeTxn(() async {
      if (data['labs'] != null) {
        for (final lab in data['labs']) {
          await _isar.labResults.put(lab as LabResult);
        }
      }
      if (data['vitals'] != null) {
        for (final vital in data['vitals']) {
          await _isar.vitalSigns.put(vital as VitalSign);
        }
      }
      // ... similar for other collections
    });
  }

  // ============ Cleanup ============

  Future<void> deleteOldData({required int daysOld}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    
    await _isar.writeTxn(() async {
      // Only delete non-essential data
      await _isar.labResults
          .filter()
          .dateLessThan(cutoff)
          .deleteAll();
          
      await _isar.vitalSigns
          .filter()
          .timestampLessThan(cutoff)
          .deleteAll();
    });
  }
}
