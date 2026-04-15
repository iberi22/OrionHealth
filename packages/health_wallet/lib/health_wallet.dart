/// Health Wallet - Private health data management for OrionHealth
///
/// This package handles:
/// - Encrypted local storage of health records
/// - Selective sync based on user profile
/// - P2P data transfer between Orion nodes
library health_wallet;

export 'models/health_record.dart';
export 'models/lab_result.dart';
export 'models/vital_sign.dart';
export 'models/medication_entry.dart';
export 'models/medical_document.dart';
export 'models/medical_event.dart';
export 'services/wallet_service.dart';
export 'services/encryption_service.dart';
export 'services/sync_service.dart';
