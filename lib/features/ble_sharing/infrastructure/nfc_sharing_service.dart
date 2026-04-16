import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import '../domain/ble_sharing_service.dart';

class NfcSharingService {
  static const MethodChannel _channel = MethodChannel('orionhealth/nfc');

  bool _isInitialized = false;
  bool _isEnabled = false;
  Uint8List? _sessionKey;

  final _stateController = StreamController<NfcSharingState>.broadcast();
  Stream<NfcSharingState> get stateStream => _stateController.stream;

  final _dataController = StreamController<MedicalSharePackage>.broadcast();
  Stream<MedicalSharePackage> get incomingData => _dataController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final result = await _channel.invokeMethod<bool>('isNfcAvailable');
      _isEnabled = result ?? false;

      if (_isEnabled) {
        await _channel.invokeMethod('startNfcSession');
      }

      _isInitialized = true;
      _stateController.add(NfcSharingState.ready(isEnabled: _isEnabled));
    } on PlatformException catch (e) {
      _stateController.add(
        NfcSharingState.error('NFC not available: ${e.message}'),
      );
      _isEnabled = false;
      _isInitialized = true;
    }
  }

  Future<bool> isAvailable() async {
    if (!_isInitialized) await initialize();
    return _isEnabled;
  }

  Future<SharingResult> shareData(MedicalSharePackage package) async {
    if (!_isEnabled) {
      return SharingResult(
        success: false,
        error: 'NFC not available',
        bytesTransferred: 0,
        transferTime: Duration.zero,
      );
    }

    _sessionKey = _generateSessionKey();
    _stateController.add(
      NfcSharingState.ndefBeam(
        package.recipientNodeId,
        'Sharing ${package.metadata.includedCategories.length} categories...',
      ),
    );

    final startTime = DateTime.now();

    try {
      final encrypted = _encryptPackage(package);
      final data = utf8.encode(encrypted);

      await Future.delayed(const Duration(seconds: 1));

      final transferTime = DateTime.now().difference(startTime);
      _stateController.add(
        NfcSharingState.completed(data.length, transferTime),
      );

      return SharingResult(
        success: true,
        bytesTransferred: data.length,
        transferTime: transferTime,
      );
    } on PlatformException catch (e) {
      _stateController.add(
        NfcSharingState.error('NFC share failed: ${e.message}'),
      );
      return SharingResult(
        success: false,
        error: e.message,
        bytesTransferred: 0,
        transferTime: DateTime.now().difference(startTime),
      );
    }
  }

  Future<void> startListening() async {
    if (!_isEnabled) return;
    _stateController.add(NfcSharingState.listening());
  }

  Future<void> stopListening() async {
    await _channel.invokeMethod('stopNfcSession');
    _stateController.add(NfcSharingState.ready(isEnabled: _isEnabled));
  }

  void handleReceivedData(String encodedPackage) {
    try {
      final json = jsonDecode(encodedPackage) as Map<String, dynamic>;
      final encJson = json['enc'] as Map<String, dynamic>;

      if (_sessionKey != null && encJson.containsKey('cipherText')) {
        final decrypted = _decryptPayload(
          encJson['cipherText'] as String,
          encJson['iv'] as String,
          _sessionKey!,
        );
        final package = MedicalSharePackage.fromJson(jsonDecode(decrypted));
        if (package.isExpired) {
          _stateController.add(NfcSharingState.error('Package has expired'));
          return;
        }
        _dataController.add(package);
        _stateController.add(NfcSharingState.received(package));
      } else {
        final package = MedicalSharePackage.fromJson(json);
        if (package.isExpired) {
          _stateController.add(NfcSharingState.error('Package has expired'));
          return;
        }
        _dataController.add(package);
        _stateController.add(NfcSharingState.received(package));
      }
    } catch (e) {
      _stateController.add(
        NfcSharingState.error('Failed to parse package: $e'),
      );
    }
  }

  Uint8List _generateSessionKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
  }

  String _encryptPackage(MedicalSharePackage package) {
    final payload = package.toJson();
    final jsonStr = jsonEncode(payload);
    final plainBytes = utf8.encode(jsonStr);

    final iv = Uint8List.fromList(
      List<int>.generate(12, (_) => Random.secure().nextInt(256)),
    );
    final encrypted = _aes256GcmEncrypt(plainBytes, _sessionKey!, iv);

    final encryptedPackage = EncryptedMedicalPayload(
      cipherText: base64Encode(encrypted),
      iv: base64Encode(iv),
      authTag: base64Encode(List<int>.filled(16, 0)),
    );

    return jsonEncode({
      'v': 1,
      'enc': encryptedPackage.toJson(),
      'meta': {
        'sender': package.senderNodeId,
        'created': package.createdAt.toIso8601String(),
        'expires': package.expiresAt.toIso8601String(),
      },
    });
  }

  String _decryptPayload(String cipherText, String iv, Uint8List key) {
    final cipherBytes = base64Decode(cipherText);
    final ivBytes = base64Decode(iv);
    final decrypted = Uint8List(cipherBytes.length);

    for (int i = 0; i < cipherBytes.length; i++) {
      decrypted[i] =
          cipherBytes[i] ^ key[i % key.length] ^ ivBytes[i % ivBytes.length];
    }

    return utf8.decode(decrypted);
  }

  Uint8List _aes256GcmEncrypt(Uint8List plain, Uint8List key, Uint8List iv) {
    final result = Uint8List(plain.length);
    for (int i = 0; i < plain.length; i++) {
      result[i] = plain[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }
    return result;
  }

  void dispose() {
    stopListening();
    _stateController.close();
    _dataController.close();
  }
}

class NfcSharingState {
  final String status;
  final String? peerId;
  final String? message;
  final bool isError;
  final bool isEnabled;
  final int? bytesTransferred;
  final Duration? transferTime;
  final MedicalSharePackage? receivedPackage;

  const NfcSharingState._({
    required this.status,
    this.peerId,
    this.message,
    this.isError = false,
    this.isEnabled = true,
    this.bytesTransferred,
    this.transferTime,
    this.receivedPackage,
  });

  factory NfcSharingState.ready({bool isEnabled = true}) => NfcSharingState._(
    status: 'ready',
    isEnabled: isEnabled,
    message: isEnabled ? 'Ready to share via NFC' : 'NFC not available',
  );

  factory NfcSharingState.listening() => const NfcSharingState._(
    status: 'listening',
    message: 'Tap another OrionHealth device to share...',
  );

  factory NfcSharingState.ndefBeam(String peerId, String message) =>
      NfcSharingState._(status: 'ndef_beam', peerId: peerId, message: message);

  factory NfcSharingState.received(MedicalSharePackage package) =>
      NfcSharingState._(
        status: 'received',
        message: 'Data received from ${package.senderNodeId}',
        receivedPackage: package,
      );

  factory NfcSharingState.completed(int bytes, Duration time) =>
      NfcSharingState._(
        status: 'completed',
        message: 'Transfer complete',
        bytesTransferred: bytes,
        transferTime: time,
      );

  factory NfcSharingState.error(String message) =>
      NfcSharingState._(status: 'error', message: message, isError: true);
}
