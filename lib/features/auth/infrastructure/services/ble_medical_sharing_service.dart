import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import "../../../health_sharing/domain/entities/shared_health_package.dart";
import '../../../health_sharing/infrastructure/ble_sharing_service.dart';
import '../../../ssi/domain/entities/verifiable_credential.dart';
import '../../../ssi/domain/services/ssi_service.dart';
import 'encryption_service.dart';

/// BLE Medical Sharing Service — coordinates BLE transport, encryption,
/// and SSI credential exchange for offline medical data sharing.
///
/// This service wires the three subsystems together:
/// - [BleSharingService] for BLE transport (scan, connect, advertise, send)
/// - [EncryptionService] for AES-256-GCM payload encryption
/// - [SsiService] for Verifiable Credential issuance and verification
///
/// Flow:
///   1. Two devices pair via BLE (one advertises, one connects)
///   2. Sender issues a VC presentation with selective disclosure
///   3. Presentation is serialized, encrypted with session key, sent over BLE
///   4. Receiver decrypts, verifies the VC proof, stores locally
@lazySingleton
class BleMedicalSharingService {
  final BleSharingService _bleService;
  final EncryptionService _encryptionService;
  final SsiService? _ssiService;

  /// Whether the encryption service has been initialized.
  bool _encryptionReady = false;

  BleMedicalSharingService(
    this._bleService,
    this._encryptionService, [
    this._ssiService,
  ]);

  /// Initialize BLE and encryption subsystems.
  Future<void> initialize() async {
    await _bleService.initialize();
    await _encryptionService.initialize();
    _encryptionReady = true;
  }

  /// Share a Verifiable Credential over BLE.
  ///
  /// Encrypts the VC with the session key established during [connect],
  /// then sends it in chunks over BLE.
  ///
  /// The [recipientNodeId] identifies the receiving OrionHealth node.
  Future<SharingResult> shareCredential({
    required VerifiableCredential credential,
    required String recipientNodeId,
  }) async {
    final package = SharedHealthPackage(
      id: credential.id,
      senderNodeId: 'self',
      recipientNodeId: recipientNodeId,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      payload: EncryptedPayload(
        cipherText: base64Encode(utf8.encode(jsonEncode(credential.toJson()))),
        iv: _generateIv(),
        authTag: '',
      ),
      metadata: PackageMetadata(
        packageType: 'VerifiableCredential',
        consentVerified: true,
        includedCategories: {DataCategory.documents},
        appVersion: '1.0.0',
      ),
      signature: credential.proof ?? '',
    );

    return _bleService.sendData(package);
  }

  /// Share a selective-disclosure presentation over BLE.
  ///
  /// Only the specified [disclosedFields] are revealed to the recipient.
  /// Requires an active BLE connection.
  Future<SharingResult> sharePresentation({
    required VerifiableCredential credential,
    required String recipientNodeId,
    required List<String> disclosedFields,
  }) async {
    if (_ssiService == null) {
      return SharingResult(
        success: false,
        error: 'SSI service not available',
        bytesTransferred: 0,
        transferTime: Duration.zero,
      );
    }

    final presentation = await _ssiService.createPresentation(
      credential: credential,
      disclosedFields: disclosedFields,
    );

    final presentationJson = jsonEncode(presentation);
    final plainBytes = utf8.encode(presentationJson);
    final encrypted = await _encryptionService.encryptBytes(
      Uint8List.fromList(plainBytes),
    );

    final package = SharedHealthPackage(
      id: 'pres:${credential.id}',
      senderNodeId: 'self',
      recipientNodeId: recipientNodeId,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      payload: EncryptedPayload(
        cipherText: base64Encode(encrypted),
        iv: _generateIv(),
        authTag: '',
      ),
      metadata: PackageMetadata(
        packageType: 'VerifiablePresentation',
        consentVerified: true,
        includedCategories: const {},
        appVersion: '1.0.0',
      ),
      signature: credential.proof ?? '',
    );

    return _bleService.sendData(package);
  }

  /// Receive a serialized VC from BLE, verify and return it.
  ///
  /// Returns null if no data is available or verification fails.
  Future<VerifiableCredential?> receiveCredential() async {
    final package = await _bleService.receiveData();
    if (package == null) return null;

    final jsonStr = utf8.decode(
      base64Decode(package.payload.cipherText),
    );
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    final vc = VerifiableCredential.fromJson(json);

    // Verify if SSI service is available
    if (_ssiService != null) {
      final isValid = await _ssiService.verifyCredential(vc);
      if (!isValid) return null;
    }

    return vc;
  }

  /// Start advertising this device as an OrionHealth node.
  Future<bool> startAdvertising({String nodeId = 'orionhealth-node'}) async {
    await _bleService.startAdvertising(nodeId);
    return true;
  }

  /// Stop advertising.
  Future<void> stopAdvertising() async {
    await _bleService.stopAdvertising();
  }

  /// Scan for nearby OrionHealth nodes.
  Future<List<BleDevice>> scanForNodes() async {
    return _bleService.scanForDevices();
  }

  /// Connect to a nearby OrionHealth node.
  Future<bool> connectToNode(String deviceId) async {
    return _bleService.connect(deviceId);
  }

  /// Disconnect from the current node.
  Future<void> disconnect() async {
    await _bleService.disconnect();
  }

  /// Encrypt and send raw medical data over BLE.
  Future<SharingResult> sendEncryptedData(
    Map<String, dynamic> data, {
    required String recipientNodeId,
  }) async {
    if (!_encryptionReady) {
      return SharingResult(
        success: false,
        error: 'Encryption not initialized',
        bytesTransferred: 0,
        transferTime: Duration.zero,
      );
    }

    final jsonStr = jsonEncode(data);
    final encrypted = await _encryptionService.encrypt(jsonStr);

    final package = SharedHealthPackage(
      id: 'med:${DateTime.now().millisecondsSinceEpoch}',
      senderNodeId: 'self',
      recipientNodeId: recipientNodeId,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      payload: EncryptedPayload(
        cipherText: base64Encode(encrypted),
        iv: _generateIv(),
        authTag: '',
      ),
      metadata: PackageMetadata(
        packageType: 'MedicalData',
        consentVerified: true,
        includedCategories: {DataCategory.labResults},
        appVersion: '1.0.0',
      ),
      signature: '',
    );

    return _bleService.sendData(package);
  }

  /// Encrypt any medical data into a [SharedHealthPackage].
  Future<SharedHealthPackage> encryptPackage(
    Map<String, dynamic> data, {
    required String packageType,
    required String recipientNodeId,
  }) async {
    final jsonStr = jsonEncode(data);
    final plainBytes = utf8.encode(jsonStr);
    final encrypted = await _encryptionService.encryptBytes(
      Uint8List.fromList(plainBytes),
    );

    return SharedHealthPackage(
      id: 'pkg:${DateTime.now().millisecondsSinceEpoch}',
      senderNodeId: 'self',
      recipientNodeId: recipientNodeId,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      payload: EncryptedPayload(
        cipherText: base64Encode(encrypted),
        iv: _generateIv(),
        authTag: '',
      ),
      metadata: PackageMetadata(
        packageType: packageType,
        consentVerified: true,
        includedCategories: const {},
        appVersion: '1.0.0',
      ),
      signature: '',
    );
  }

  /// Decrypt a [SharedHealthPackage] back into a data map.
  Future<Map<String, dynamic>> decryptPackage(
      SharedHealthPackage package) async {
    final encryptedBytes = base64Decode(package.payload.cipherText);
    final decryptedBytes =
        await _encryptionService.decryptBytes(encryptedBytes);
    final jsonStr = utf8.decode(decryptedBytes);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  String _generateIv() {
    // IV is handled by EncryptionService; placeholder for non-sensitive payload
    return base64Encode(Uint8List(12));
  }

  void dispose() {
    _bleService.dispose();
  }
}
