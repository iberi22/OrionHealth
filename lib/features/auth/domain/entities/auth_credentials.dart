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

extension AuthCredentialsX on AuthCredentials {
  Duration get lockoutDuration {
    if (failedAttempts >= 10) return const Duration(minutes: 60);
    if (failedAttempts >= 9) return const Duration(minutes: 30);
    if (failedAttempts >= 8) return const Duration(minutes: 15);
    if (failedAttempts >= 7) return const Duration(minutes: 5);
    if (failedAttempts >= 5) return const Duration(minutes: 1);
    return Duration.zero;
  }

  DateTime? get lockoutUntil {
    if (lastLockoutTime == null) return null;
    final duration = lockoutDuration;
    if (duration == Duration.zero) return null;
    return lastLockoutTime!.add(duration);
  }

  bool get isLocked {
    final until = lockoutUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }
}
