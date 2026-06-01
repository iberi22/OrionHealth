import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

import '../../domain/services/vector_store_service.dart';
import '../../../health_record/domain/repositories/health_record_repository.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../../allergies/domain/repositories/allergy_repository.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

import '../../../health_record/domain/entities/medical_record.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../allergies/domain/entities/allergy.dart';
import '../../../vitals/domain/entities/vital_sign.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../../core/services/app_logger.dart';

/// Service that indexes patient health records into the vector store.
///
/// It monitors Isar collections for changes and automatically updates the
/// vector store to ensure the AI agent has up-to-date context about the patient.
@LazySingleton()
class PatientContextIndexer {
  static const _tag = 'PatientContextIndexer';

  final Isar _isar;
  final VectorStoreService _vectorStore;
  final HealthRecordRepository _healthRecordRepo;
  final MedicationRepository _medicationRepo;
  final AllergyRepository _allergyRepo;
  final VitalSignRepository _vitalRepo;
  final AppointmentRepository _appointmentRepo;

  StreamSubscription? _healthRecordSub;
  StreamSubscription? _medicationSub;
  StreamSubscription? _allergySub;
  StreamSubscription? _vitalSub;
  StreamSubscription? _appointmentSub;

  Timer? _debounceTimer;

  PatientContextIndexer(
    this._isar,
    this._vectorStore,
    this._healthRecordRepo,
    this._medicationRepo,
    this._allergyRepo,
    this._vitalRepo,
    this._appointmentRepo,
  );

  /// Index all current patient records and start watching for changes.
  Future<void> indexAll() async {
    AppLogger.i(_tag, 'Indexing all patient records...');
    await _performFullIndex();
    _setupWatchers();
  }

  Future<void> _performFullIndex() async {
    await Future.wait([
      _indexHealthRecords(),
      _indexMedications(),
      _indexAllergies(),
      _indexVitalSigns(),
      _indexAppointments(),
    ]);
  }

  void _setupWatchers() {
    _healthRecordSub?.cancel();
    _healthRecordSub = _isar.medicalRecords.watchLazy().listen((_) => _debouncedIndex());

    _medicationSub?.cancel();
    _medicationSub = _isar.medications.watchLazy().listen((_) => _debouncedIndex());

    _allergySub?.cancel();
    _allergySub = _isar.allergys.watchLazy().listen((_) => _debouncedIndex());

    _vitalSub?.cancel();
    _vitalSub = _isar.vitalSigns.watchLazy().listen((_) => _debouncedIndex());

    _appointmentSub?.cancel();
    _appointmentSub = _isar.appointments.watchLazy().listen((_) => _debouncedIndex());
  }

  void _debouncedIndex() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _performFullIndex();
    });
  }

  Future<void> _indexHealthRecords() async {
    try {
      final records = await _healthRecordRepo.getAllRecords();
      for (final record in records) {
        final dateStr = record.date?.toIso8601String() ?? '';
        final text = 'Registro Médico: ${record.type.name} - Resumen: ${record.summary ?? 'Sin resumen'} - Fecha: ${dateStr.isEmpty ? 'N/A' : dateStr}\n${record.attachments.map((a) => a.extractedText).where((t) => t != null && t.isNotEmpty).join('\n')}';

        await _vectorStore.addDocument(
          'patient:medical_record:${record.id}',
          text.trim(),
          {
            'type': 'patient_record',
            'source': 'medical_record',
            'date': dateStr,
            'id': record.id,
          },
        );
      }
    } catch (e) {
      AppLogger.e(_tag, 'Error indexing health records', error: e);
    }
  }

  Future<void> _indexMedications() async {
    try {
      final medications = await _medicationRepo.getAllMedications();
      for (final med in medications) {
        final startStr = med.startDate.toIso8601String();
        final text = 'Medicamento: ${med.name} - Dosis: ${med.dosage ?? 'N/A'} - Frecuencia: ${med.frequency ?? 'N/A'} - Notas: ${med.notes ?? 'N/A'} - Inicio: $startStr - Activo: ${med.isActive ? 'Sí' : 'No'}';

        await _vectorStore.addDocument(
          'patient:medication:${med.id}',
          text,
          {
            'type': 'patient_record',
            'source': 'medication',
            'date': startStr,
            'id': med.id,
          },
        );
      }
    } catch (e) {
      AppLogger.e(_tag, 'Error indexing medications', error: e);
    }
  }

  Future<void> _indexAllergies() async {
    try {
      final allergies = await _allergyRepo.getAllergies();
      for (final allergy in allergies) {
        final allergen = allergy.allergen ?? 'Desconocida';
        final text = 'Alergia: $allergen - Severidad: ${allergy.severity.name} - Notas: ${allergy.notes ?? 'N/A'}';

        await _vectorStore.addDocument(
          'patient:allergy:${allergy.id}',
          text,
          {
            'type': 'patient_record',
            'source': 'allergy',
            'id': allergy.id,
          },
        );
      }
    } catch (e) {
      AppLogger.e(_tag, 'Error indexing allergies', error: e);
    }
  }

  Future<void> _indexVitalSigns() async {
    try {
      final vitals = await _vitalRepo.getAllVitalSigns();
      for (final vital in vitals) {
        final dateStr = vital.dateTime.toIso8601String();
        final text = 'Signo Vital: ${vital.type.name} - Valor: ${vital.formattedValue} - Fecha: ${dateStr.isEmpty ? 'N/A' : dateStr} - Notas: ${vital.notes ?? 'N/A'}';

        await _vectorStore.addDocument(
          'patient:vital_sign:${vital.id}',
          text,
          {
            'type': 'patient_record',
            'source': 'vital_sign',
            'date': dateStr,
            'id': vital.id,
          },
        );
      }
    } catch (e) {
      AppLogger.e(_tag, 'Error indexing vital signs', error: e);
    }
  }

  Future<void> _indexAppointments() async {
    try {
      final appointments = await _appointmentRepo.getAllAppointments();
      for (final appt in appointments) {
        final dateStr = appt.dateTime.toIso8601String();
        final typeLabel = appt.doctorName.isNotEmpty ? 'Consulta con ${appt.doctorName}' : 'Cita';
        final text = 'Cita: $typeLabel - Doctor: ${appt.doctorName} - Especialidad: ${appt.specialty} - Fecha: ${dateStr.isEmpty ? 'N/A' : dateStr} - Estado: ${appt.status.name} - Notas: ${appt.notes ?? 'N/A'}';

        await _vectorStore.addDocument(
          'patient:appointment:${appt.id}',
          text,
          {
            'type': 'patient_record',
            'source': 'appointment',
            'date': dateStr,
            'id': appt.id,
          },
        );
      }
    } catch (e) {
      AppLogger.e(_tag, 'Error indexing appointments', error: e);
    }
  }

  @disposeMethod
  void dispose() {
    _healthRecordSub?.cancel();
    _medicationSub?.cancel();
    _allergySub?.cancel();
    _vitalSub?.cancel();
    _appointmentSub?.cancel();
    _debounceTimer?.cancel();
  }
}
