import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BiometricService biometricService;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    biometricService = BiometricService();
    log.clear();

    // The channel name for local_auth package
    const MethodChannel channel = MethodChannel('plugins.flutter.io/local_auth');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'canCheckBiometrics':
          return true;
        case 'isDeviceSupported':
          return true;
        case 'getAvailableBiometrics':
          return <String>['fingerprint', 'face'];
        case 'authenticate':
          return true;
        default:
          return null;
      }
    });
  });

  group('BiometricService', () {
    test('isBiometricAvailable returns true when supported', () async {
      final result = await biometricService.isBiometricAvailable();
      expect(result, isTrue);
    });

    test('getAvailableBiometrics returns list of biometrics', () async {
      final result = await biometricService.getAvailableBiometrics();
      expect(result, contains(BiometricType.fingerprint));
      expect(result, contains(BiometricType.face));
    });

    test('authenticate returns true on success', () async {
      final result = await biometricService.authenticate(localizedReason: 'test');
      expect(result, isTrue);
      expect(log, anyElement(predicate((MethodCall m) => m.method == 'authenticate')));
    });

    test('authenticate returns false on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/local_auth'), (MethodCall methodCall) async {
        if (methodCall.method == 'authenticate') {
          throw PlatformException(code: 'error');
        }
        return null;
      });

      final result = await biometricService.authenticate(localizedReason: 'test');
      expect(result, isFalse);
    });
  });
}
