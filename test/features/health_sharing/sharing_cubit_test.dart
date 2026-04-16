import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/health_sharing/domain/entities/shared_health_package.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class FakeBleSharingService implements BleSharingService {
  @override
  Stream<List<ScanResult>> scanForDevices() => Stream.value([]);

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> sendData(BluetoothDevice device, String encryptedData) async {}

  @override
  Stream<String> receiveData() => const Stream.empty();
}

class FakeEncryptionService implements EncryptionService {
  @override
  Future<void> initialize() async {}

  @override
  Future<String> generateShareSessionKey() async => 'fake_session_key';

  @override
  Future<String> encryptForSharing(String data, String sessionKeyBase64) async => 'fake_encrypted_data';

  @override
  Future<String> decryptSharedData(String encryptedData, String sessionKeyBase64) async => '{"sharedAt": "${DateTime.now().toIso8601String()}"}';

  // Other methods from EncryptionService that might be needed
  @override
  Future<String> encrypt(String plaintext) async => '';
  @override
  Future<String> decrypt(String encryptedData) async => '';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBluetoothDevice extends Fake implements BluetoothDevice {
  @override
  String get platformName => 'Fake Device';
  @override
  DeviceIdentifier get remoteId => const DeviceIdentifier('00:11:22:33:44:55');
}

void main() {
  late SharingCubit cubit;
  late FakeBleSharingService fakeBleService;
  late FakeEncryptionService fakeEncryptionService;

  setUp(() {
    fakeBleService = FakeBleSharingService();
    fakeEncryptionService = FakeEncryptionService();
    cubit = SharingCubit(fakeBleService, fakeEncryptionService);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is SharingInitial', () {
    expect(cubit.state, SharingInitial());
  });

  test('startScanning emits SharingScanning', () {
    cubit.startScanning();
    expect(cubit.state, isA<SharingScanning>());
  });

  test('shareData performs encryption and calls sendData', () async {
    final fakeDevice = FakeBluetoothDevice();
    final package = SharedHealthPackage();

    await cubit.shareData(fakeDevice, package);

    expect(cubit.state, const SharingSuccess("Datos enviados exitosamente"));
  });
}
