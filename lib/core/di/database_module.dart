// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/api_audit_log.dart';
import '../../features/user_profile/domain/entities/user_profile.dart';
import '../../features/local_agent/domain/chat_message.dart';
import '../../features/health_record/domain/entities/medical_record.dart';
import '../../features/reports/domain/entities/report.dart';
import '../../features/medications/domain/entities/medication.dart';
import '../../features/vitals/domain/entities/vital_sign.dart';
import '../../features/appointments/domain/entities/appointment.dart';
import '../../features/allergies/domain/entities/allergy.dart';
import '../../features/health_report/domain/entities/health_report.dart';
import '../../features/ssi/infrastructure/persistence/isar_did.dart';
import '../../features/ssi/infrastructure/persistence/isar_credential.dart';
import '../../features/ssi/infrastructure/persistence/isar_revocation_entry.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:health_wallet/health_wallet.dart' hide HealthRecord, LabResult, VitalSign, VitalSignSchema, MedicationEntry, MedicalDocument, MedicalEvent;

@module
abstract class DatabaseModule {
  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [
        UserProfileSchema,
        ApiAuditLogSchema,
        ChatMessageSchema,
        MedicalRecordSchema,
        MemoryNodeSchema,
        MemoryEdgeSchema,
        ReportSchema,
        MedicationSchema,
        AppointmentSchema,
        AllergySchema,
        HealthReportSchema,
        HealthRecordSchema,
        LabResultSchema,
        VitalSignSchema,
        MedicationEntrySchema,
        MedicalDocumentSchema,
        MedicalEventSchema,
        IsarDidSchema,
        IsarCredentialSchema,
        IsarRevocationEntrySchema,
      ],
      directory: dir.path,
    );
  }
}
