import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/nfc_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NfcHandler nfcHandler;
  const MethodChannel channel = MethodChannel(kNfcChannelName);
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    nfcHandler = NfcHandler(channel: channel);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'isNfcAvailable') {
        return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NfcHandler', () {
    test('isNativeAvailable is true by default', () {
        expect(nfcHandler.isNativeAvailable, isTrue);
    });

    test('startNfcSession invokes native method', () async {
      final success = await nfcHandler.startNfcSession();
      expect(success, isTrue);
      expect(log.first.method, 'startNfcSession');
    });

    test('stopNfcSession invokes native method', () async {
      await nfcHandler.stopNfcSession();
      expect(log.first.method, 'stopNfcSession');
    });

    test('beamNdefMessage invokes native method with data', () async {
      await nfcHandler.beamNdefMessage([1, 2, 3]);
      expect(log.first.method, 'beamNdefMessage');
      expect(log.first.arguments['data'], [1, 2, 3]);
    });

    test('isNfcAvailable sets _nativeAvailable to false on non-mobile', () async {
        final available = await nfcHandler.isNfcAvailable();
        expect(available, isFalse);
        expect(nfcHandler.isNativeAvailable, isFalse);
    });
  });
}
