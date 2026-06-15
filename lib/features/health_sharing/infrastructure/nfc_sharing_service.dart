import 'dart:async';
import 'dart:io' show Platform;

import 'package:injectable/injectable.dart';
import '../domain/entities/shared_health_package.dart';
import 'nfc_handler.dart';

/// NFC sharing service for tap-to-share health data
///
/// Uses [NfcHandler] as a platform-aware wrapper around the native
/// method channel. On platforms without native NFC support, falls back
/// gracefully rather than crashing.
@lazySingleton
class NfcSharingService {
  final NfcHandler _nfcHandler;
  bool _isInitialized = false;
  bool _isEnabled = false;

  final _stateController = StreamController<NfcSharingState>.broadcast();
  Stream<NfcSharingState> get stateStream => _stateController.stream;

  final _dataController = StreamController<SharedHealthPackage>.broadcast();
  Stream<SharedHealthPackage> get incomingData => _dataController.stream;

  NfcSharingService({NfcHandler? nfcHandler})
      : _nfcHandler = nfcHandler ?? NfcHandler();

  /// Initialize NFC adapter.
  ///
  /// On platforms without native NFC support (desktop, web, or when the
  /// native plugin is unregistered), sets [_isEnabled] to false and
  /// emits a ready state without throwing.
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!(Platform.isAndroid || Platform.isIOS)) {
      _isEnabled = false;
      _isInitialized = true;
      _stateController.add(NfcSharingState.ready(isEnabled: false));
      return;
    }

    try {
      _isEnabled = await _nfcHandler.isNfcAvailable();

      if (_isEnabled) {
        await _nfcHandler.startNfcSession();
      }

      _isInitialized = true;
      _stateController.add(NfcSharingState.ready(isEnabled: _isEnabled));
    } catch (e) {
      _stateController.add(NfcSharingState.error('NFC not available: $e'));
      _isEnabled = false;
      _isInitialized = true;
    }
  }

  /// Check if NFC is available and enabled
  Future<bool> isAvailable() async {
    if (!_isInitialized) await initialize();
    return _isEnabled;
  }

  /// Share data via NFC beam.
  ///
  /// Uses [NfcHandler.beamNdefMessage] to invoke native NFC data
  /// transfer. Returns a [SharingResult] indicating success or failure.
  Future<SharingResult> shareData(SharedHealthPackage package) async {
    if (!_isEnabled) {
      return SharingResult(
        success: false,
        error: 'NFC not available',
        bytesTransferred: 0,
        transferTime: Duration.zero,
      );
    }

    _stateController.add(NfcSharingState.ndefBeam(
      package.recipientNodeId,
      'Sharing ${package.metadata.includedCategories.length} categories...',
    ));

    final startTime = DateTime.now();

    try {
      final data = package.encode();
      final bytes = data.codeUnits;

      await _nfcHandler.beamNdefMessage(bytes);

      final transferTime = DateTime.now().difference(startTime);

      _stateController.add(NfcSharingState.completed(
        bytes.length,
        transferTime,
      ));

      return SharingResult(
        success: true,
        bytesTransferred: bytes.length,
        transferTime: transferTime,
      );
    } catch (e) {
      _stateController.add(NfcSharingState.error('NFC share failed: $e'));
      return SharingResult(
        success: false,
        error: e.toString(),
        bytesTransferred: 0,
        transferTime: DateTime.now().difference(startTime),
      );
    }
  }

  /// Start listening for incoming NFC data.
  ///
  /// In production, this enables the native NFC reader session which
  /// triggers the [handleReceivedData] callback when an NDEF message
  /// is received.
  Future<void> startListening() async {
    if (!_isEnabled) return;

    _stateController.add(NfcSharingState.listening());

    await _nfcHandler.startNfcSession();
  }

  /// Stop listening for NFC.
  Future<void> stopListening() async {
    await _nfcHandler.stopNfcSession();
    _stateController.add(NfcSharingState.ready(isEnabled: _isEnabled));
  }

  /// Handle received NFC data (called from native side)
  void handleReceivedData(String encodedPackage) {
    try {
      final package = SharedHealthPackage.decode(encodedPackage);

      if (package.isExpired) {
        _stateController.add(NfcSharingState.error('Package has expired'));
        return;
      }

      _dataController.add(package);
      _stateController.add(NfcSharingState.received(package));
    } catch (e) {
      _stateController.add(NfcSharingState.error('Failed to parse package: $e'));
    }
  }

  /// Clean up resources
  void dispose() {
    stopListening();
    _stateController.close();
    _dataController.close();
  }
}

/// State of NFC sharing service
class NfcSharingState {
  final String status;
  final String? peerId;
  final String? message;
  final bool isError;
  final bool isEnabled;
  final int? bytesTransferred;
  final Duration? transferTime;
  final SharedHealthPackage? receivedPackage;

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

  factory NfcSharingState.ndefBeam(String peerId, String message) => NfcSharingState._(
        status: 'ndef_beam',
        peerId: peerId,
        message: message,
      );

  factory NfcSharingState.received(SharedHealthPackage package) => NfcSharingState._(
        status: 'received',
        message: 'Data received from ${package.senderNodeId}',
        receivedPackage: package,
      );

  factory NfcSharingState.completed(int bytes, Duration time) => NfcSharingState._(
        status: 'completed',
        message: 'Transfer complete',
        bytesTransferred: bytes,
        transferTime: time,
      );

  factory NfcSharingState.error(String message) => NfcSharingState._(
        status: 'error',
        message: message,
        isError: true,
      );
}
