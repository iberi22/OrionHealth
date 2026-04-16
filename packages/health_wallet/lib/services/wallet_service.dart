import 'package:isar/isar.dart';
import '../models/health_record.dart';
import '../models/lab_result.dart';
import '../models/vital_sign.dart';
import '../models/medication_entry.dart';
import '../models/medical_document.dart';
import '../models/medical_event.dart';
import 'encryption_service.dart';

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
    final results = await _isar.labResults
        .filter()
        .loincCodeEqualTo(loincCode)
        .findAll();
    results.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
    return results;
  }

  Future<List<LabResult>> getRecentLabs({int days = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final results = await _isar.labResults
        .filter()
        .collectedAtGreaterThan(cutoff)
        .findAll();
    results.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
    return results;
  }

  // ============ Vitals ============

  Future<void> addVitalSign(VitalSign vital) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vital);
    });
  }

  Future<List<VitalSign>> getVitalsByType(String vitalType) async {
    final results = await _isar.vitalSigns
        .filter()
        .loincCodeEqualTo(vitalType)
        .findAll();
    results.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return results;
  }

  Future<List<VitalSign>> getVitalsRange({
    required String vitalType,
    required DateTime from,
    required DateTime to,
  }) async {
    final results = await _isar.vitalSigns
        .filter()
        .loincCodeEqualTo(vitalType)
        .recordedAtBetween(from, to)
        .findAll();
    results.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return results;
  }

  // ============ Medications ============

  Future<void> addMedication(MedicationEntry med) async {
    await _isar.writeTxn(() async {
      await _isar.medicationEntrys.put(med);
    });
  }

  Future<List<MedicationEntry>> getActiveMedications() async {
    final results = await _isar.medicationEntrys
        .filter()
        .endDateIsNull()
        .findAll();
    results.sort((a, b) => a.medicationName.compareTo(b.medicationName));
    return results;
  }

  Future<List<MedicationEntry>> getMedicationsByRxNorm(String rxNormCode) async {
    return _isar.medicationEntrys
        .filter()
        .rxNormCodeEqualTo(rxNormCode)
        .findAll();
  }

  // ============ Medical Events ============

  Future<void> addMedicalEvent(MedicalEvent event) async {
    await _isar.writeTxn(() async {
      await _isar.medicalEvents.put(event);
    });
  }

  Future<List<MedicalEvent>> getEventsByType(EventType eventType) async {
    final results = await _isar.medicalEvents
        .filter()
        .eventTypeEqualTo(eventType)
        .findAll();
    results.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return results;
  }

  Future<List<MedicalEvent>> getTimeline({
    DateTime? from,
    DateTime? to,
  }) async {
    List<MedicalEvent> results;
    if (from != null && to != null) {
      results = await _isar.medicalEvents
          .filter()
          .eventDateBetween(from, to)
          .findAll();
    } else {
      results = await _isar.medicalEvents.where().findAll();
    }
    results.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return results;
  }

  // ============ Documents ============

  Future<void> addDocument(MedicalDocument doc) async {
    final encrypted = await _encryption.encryptDocument(doc);
    await _isar.writeTxn(() async {
      await _isar.medicalDocuments.put(encrypted);
    });
  }

  Future<List<MedicalDocument>> getDocumentsByType(DocumentType docType) async {
    final results = _isar.medicalDocuments
        .filter()
        .documentTypeMatches(docType.name)
        .sortByDocumentDateDesc()
        .findAll();
    return results;
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
      'medications': await _isar.medicationEntrys.count(),
      'events': await _isar.medicalEvents.count(),
      'documents': await _isar.medicalDocuments.count(),
    };
  }

  // ============ Export/Import ============

  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'labs': await _isar.labResults.where().findAll(),
      'vitals': await _isar.vitalSigns.where().findAll(),
      'medications': await _isar.medicationEntrys.where().findAll(),
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
      if (data['medications'] != null) {
        for (final med in data['medications']) {
          await _isar.medicationEntrys.put(med as MedicationEntry);
        }
      }
      if (data['events'] != null) {
        for (final evt in data['events']) {
          await _isar.medicalEvents.put(evt as MedicalEvent);
        }
      }
      if (data['documents'] != null) {
        for (final doc in data['documents']) {
          await _isar.medicalDocuments.put(doc as MedicalDocument);
        }
      }
    });
  }

  // ============ Cleanup ============

  Future<void> deleteOldData({required int daysOld}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));

    await _isar.writeTxn(() async {
      await _isar.labResults
          .filter()
          .collectedAtLessThan(cutoff)
          .deleteAll();

      await _isar.vitalSigns
          .filter()
          .recordedAtLessThan(cutoff)
          .deleteAll();
    });
  }
}
