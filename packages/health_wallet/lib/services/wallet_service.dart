import 'package:isar/isar.dart';
import '../models/health_record.dart';
import '../models/lab_result.dart';
import '../models/vital_sign.dart';
import '../models/medication_entry.dart';
import '../models/medical_document.dart';
import '../models/medical_event.dart';
import 'encryption_service.dart';

/// Main service for managing the health wallet.
/// Coordinates Isar collections and encryption for all health data.
class WalletService {
  WalletService(this._isar, this._encryption);

  final Isar _isar;
  final EncryptionService _encryption;

  // ─── Labs ────────────────────────────────────────────────────────────────

  Future<void> addLabResult(LabResult lab) async {
    await _isar.writeTxn(() async {
      await _isar.labResults.put(lab);
    });
  }

  Future<List<LabResult>> getLabsByLoinc(String loincCode) async {
    return _isar.labResults
        .filter()
        .loincCodeEqualTo(loincCode)
        .sortByCollectedAtDesc()
        .findAll();
  }

  Future<List<LabResult>> getRecentLabs({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _isar.labResults
        .filter()
        .collectedAtGreaterThan(cutoff)
        .sortByCollectedAtDesc()
        .findAll();
  }

  Future<void> updateLabSyncStatus(String id, SyncStatus status) async {
    await _isar.writeTxn(() async {
      final lab = await _isar.labResults.get(id);
      if (lab != null) {
        await _isar.labResults.put(lab.copyWith(syncStatus: status));
      }
    });
  }

  // ─── Vitals ──────────────────────────────────────────────────────────────

  Future<void> addVitalSign(VitalSign vital) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vital);
    });
  }

  Future<List<VitalSign>> getVitalsByLoinc(String loincCode) async {
    return _isar.vitalSigns
        .filter()
        .loincCodeEqualTo(loincCode)
        .sortByRecordedAtDesc()
        .findAll();
  }

  Future<List<VitalSign>> getVitalsRange({
    required String loincCode,
    required DateTime from,
    required DateTime to,
  }) async {
    return _isar.vitalSigns
        .filter()
        .loincCodeEqualTo(loincCode)
        .recordedAtBetween(from, to)
        .sortByRecordedAt()
        .findAll();
  }

  // ─── Medications ─────────────────────────────────────────────────────────

  Future<void> addMedication(MedicationEntry med) async {
    await _isar.writeTxn(() async {
      await _isar.medicationEntries.put(med);
    });
  }

  Future<List<MedicationEntry>> getActiveMedications() async {
    return _isar.medicationEntries
        .filter()
        .endDateIsNull()
        .sortByMedicationName()
        .findAll();
  }

  Future<List<MedicationEntry>> getMedicationsByRxNorm(String rxNormCode) async {
    return _isar.medicationEntries
        .filter()
        .rxNormCodeEqualTo(rxNormCode)
        .findAll();
  }

  // ─── Medical Events ──────────────────────────────────────────────────────

  Future<void> addMedicalEvent(MedicalEvent event) async {
    await _isar.writeTxn(() async {
      await _isar.medicalEvents.put(event);
    });
  }

  Future<List<MedicalEvent>> getEventsByType(EventType type) async {
    return _isar.medicalEvents
        .filter()
        .eventTypeEqualTo(type)
        .sortByEventDateDesc()
        .findAll();
  }

  Future<List<MedicalEvent>> getTimeline({DateTime? from, DateTime? to}) async {
    var query = _isar.medicalEvents.filter();
    if (from != null && to != null) {
      return query.eventDateBetween(from, to).sortByEventDateDesc().findAll();
    }
    return query.sortByEventDateDesc().findAll();
  }

  // ─── Documents ────────────────────────────────────────────────────────────

  Future<void> addDocument(MedicalDocument doc) async {
    await _isar.writeTxn(() async {
      await _isar.medicalDocuments.put(doc);
    });
  }

  Future<List<MedicalDocument>> getDocumentsByType(DocumentType type) async {
    return _isar.medicalDocuments
        .filter()
        .documentTypeEqualTo(type)
        .sortByDocumentDateDesc()
        .findAll();
  }

  // ─── Health Record ───────────────────────────────────────────────────────

  Future<HealthRecord?> getHealthRecord() async {
    final records = _isar.healthRecords.where().findAllSync();
    return records.isEmpty ? null : records.first;
  }

  Future<void> saveHealthRecord(HealthRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.healthRecords.put(record);
    });
  }

  // ─── Statistics ─────────────────────────────────────────────────────────

  Future<Map<String, int>> getDataStatistics() async {
    return {
      'labs': _isar.labResults.countSync(),
      'vitals': _isar.vitalSigns.countSync(),
      'medications': _isar.medicationEntries.countSync(),
      'events': _isar.medicalEvents.countSync(),
      'documents': _isar.medicalDocuments.countSync(),
    };
  }

  Future<List<LabResult>> getPendingSyncLabs() async {
    return _isar.labResults
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();
  }

  // ─── Export / Import ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'labs': _isar.labResults.where().findAllSync().map((e) => e.toJson()).toList(),
      'vitals': _isar.vitalSigns.where().findAllSync().map((e) => e.toJson()).toList(),
      'medications': _isar.medicationEntries.where().findAllSync().map((e) => e.toJson()).toList(),
      'events': _isar.medicalEvents.where().findAllSync().map((e) => e.toJson()).toList(),
      'documents': _isar.medicalDocuments.where().findAllSync().map((e) => e.toJson()).toList(),
      'healthRecord': _isar.healthRecords.where().findAllSync().map((e) => e.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  Future<int> deleteLabsOlderThan(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _isar.writeTxn(() async {
      return _isar.labResults
          .filter()
          .collectedAtLessThan(cutoff)
          .deleteAll();
    });
  }

  Future<int> deleteVitalsOlderThan(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _isar.writeTxn(() async {
      return _isar.vitalSigns
          .filter()
          .recordedAtLessThan(cutoff)
          .deleteAll();
    });
  }
}
