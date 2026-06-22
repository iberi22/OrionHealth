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
import '../../features/doctor_verification/domain/entities/doctor_profile.dart';
import '../../features/doctor_verification/domain/entities/doctor_rating.dart';
import '../../features/doctor_verification/domain/entities/vouch.dart';
import '../../features/doctor_verification/domain/entities/reputation_badge.dart';
import '../../features/doctor_verification/domain/entities/second_opinion.dart';
import '../../features/doctor_verification/domain/entities/license_registry.dart';
// SSI schemas removed in #548 (dead code cleanup)
// import '../../features/ssi/infrastructure/persistence/isar_did.dart';
// import '../../features/ssi/infrastructure/persistence/isar_credential.dart';
// import '../../features/ssi/infrastructure/persistence/isar_revocation_entry.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:health_wallet/health_wallet.dart' as wallet;

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
        DoctorProfileSchema,
        DoctorRatingSchema,
        VouchSchema,
        ReputationBadgeSchema,
        SecondOpinionRequestSchema,
        SecondOpinionResponseSchema,
        LicenseRegistryLocalSchema,
        wallet.HealthRecordSchema,
        wallet.LabResultSchema,
        wallet.VitalSignSchema,
        wallet.MedicationEntrySchema,
        wallet.MedicalDocumentSchema,
        wallet.MedicalEventSchema,
        // IsarDidSchema, // removed in #548
        // IsarCredentialSchema, // removed in #548
        // IsarRevocationEntrySchema, // removed in #548
      ],
      directory: dir.path,
    );
  }

  @lazySingleton
  wallet.EncryptionService get walletEncryptionService => wallet.EncryptionService();

  @lazySingleton
  wallet.WalletService walletService(Isar isar, wallet.EncryptionService encryption) =>
      wallet.WalletService(isar, encryption);
}
