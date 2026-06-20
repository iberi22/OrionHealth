import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/auth/infrastructure/biometric_auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BiometricAuthServiceImpl biometricService;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    biometricService = BiometricAuthServiceImpl();
    log.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('local_auth'), (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'isDeviceSupported':
          return true;
        case 'getAvailableBiometrics':
          return <String>['face', 'fingerprint'];
        case 'authenticate':
          return true;
        default:
          return null;
      }
    });
  });

  group('BiometricAuthServiceImpl', () {
    test('isAvailable returns true when supported', () async {
      final result = await biometricService.isAvailable();
      expect(result, isTrue);
    });

    test('getAvailableType returns face when face is present', () async {
      final result = await biometricService.getAvailableType();
      expect(result, BiometricType.face);
    });

    test('getAvailableType returns fingerprint when only fingerprint is present', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('local_auth'), (MethodCall methodCall) async {
        if (methodCall.method == 'getAvailableBiometrics') {
          return <String>['fingerprint'];
        }
        return null;
      });

      final result = await biometricService.getAvailableType();
      expect(result, BiometricType.fingerprint);
    });

    test('authenticate returns success when platform returns true', () async {
      final result = await biometricService.authenticate(reason: 'test');
      expect(result.success, isTrue);
      expect(result.type, BiometricType.face);
      expect(log, anyElement(predicate((m) => (m as MethodCall).method == 'authenticate')));
    });

    test('authenticate returns failure on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('local_auth'), (MethodCall methodCall) async {
        if (methodCall.method == 'authenticate') {
          throw PlatformException(code: 'error', message: 'failed');
        }
        return null;
      });

      final result = await biometricService.authenticate();
      expect(result.success, isFalse);
      expect(result.error, 'failed');
    });
  });
}
