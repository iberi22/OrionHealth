/// Health Wallet — Private health data management for OrionHealth.
///
/// Handles:
/// - Encrypted local storage of health records via Isar
/// - AES-256-GCM encryption for sensitive fields
/// - P2P encrypted sync between Orion nodes
library;

export 'models/health_record.dart';
export 'models/lab_result.dart';
export 'models/vital_sign.dart';
export 'models/medication_entry.dart';
export 'models/medical_document.dart';
export 'models/medical_event.dart';
export 'models/medical_concept.dart';
export 'services/wallet_service.dart';
export 'services/encryption_service.dart';
export 'services/sync_service.dart';
