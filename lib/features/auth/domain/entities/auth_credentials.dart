import 'package:isar/isar.dart';

part 'auth_credentials.g.dart';

@collection
class AuthCredentials {
  Id id = Isar.autoIncrement;

  String? hashedPin;
  String? salt;

  bool biometricEnabled = false;

  DateTime? lastLockoutTime;
  int failedAttempts = 0;

  @override
  String toString() {
    return 'AuthCredentials(id: $id, biometricEnabled: $biometricEnabled, failedAttempts: $failedAttempts)';
  }
}
