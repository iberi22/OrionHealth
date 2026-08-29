import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';

@visibleForTesting
class MockEncryptionService extends Mock implements EncryptionService {}
