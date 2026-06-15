import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// NFC method channel name used by [NfcSharingService].
const String kNfcChannelName = 'orionhealth/nfc';

/// Provides a platform-aware wrapper around the NFC native channel.
///
/// On Android and iOS with native NFC handler registered, delegates to
/// the platform's MethodChannel implementation. On other platforms, or
/// when the native plugin is not registered, provides a graceful
/// fallback that logs a warning and returns a "not available" state
/// without crashing.
class NfcHandler {
  final MethodChannel _channel;
  bool _nativeAvailable = true;

  /// Creates an [NfcHandler] for the given [channel].
  ///
  /// If [channel] is omitted, defaults to MethodChannel('orionhealth/nfc').
  NfcHandler({MethodChannel? channel})
      : _channel = channel ?? MethodChannel(kNfcChannelName);

  /// Whether the platform supports native NFC operations.
  bool get isNativeAvailable => _nativeAvailable;

  /// Initialize the NFC handler.
  ///
  /// Calls the native `isNfcAvailable` method on platforms that support
  /// NFC (Android/iOS). On other platforms, or if the native plugin is
  /// unregistered, sets [_nativeAvailable] to false and returns false
  /// gracefully.
  Future<bool> isNfcAvailable() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      _nativeAvailable = false;
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('isNfcAvailable');
      _nativeAvailable = result ?? false;
      return _nativeAvailable;
    } on MissingPluginException {
      _nativeAvailable = false;
      // ignore: avoid_print
      print(
        '[NfcHandler] Native NFC plugin not registered. '
        'NFC features will be unavailable.',
      );
      return false;
    } catch (e) {
      _nativeAvailable = false;
      // ignore: avoid_print
      print('[NfcHandler] NFC initialization error: $e');
      return false;
    }
  }

  /// Start an NFC session on the native side.
  ///
  /// Gracefully returns false if the native handler is unavailable.
  Future<bool> startNfcSession() async {
    if (!_nativeAvailable) return false;

    try {
      await _channel.invokeMethod('startNfcSession');
      return true;
    } on MissingPluginException {
      _nativeAvailable = false;
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[NfcHandler] startNfcSession error: $e');
      return false;
    }
  }

  /// Stop the NFC session on the native side.
  Future<void> stopNfcSession() async {
    if (!_nativeAvailable) return;

    try {
      await _channel.invokeMethod('stopNfcSession');
    } on MissingPluginException {
      _nativeAvailable = false;
    } catch (_) {
      // Best-effort stop.
    }
  }

  /// Beam an NDEF message to the other device (payload in [data]).
  Future<void> beamNdefMessage(List<int> data) async {
    if (!_nativeAvailable) return;

    try {
      await _channel.invokeMethod('beamNdefMessage', {
        'data': data,
      });
    } on MissingPluginException {
      _nativeAvailable = false;
    } catch (_) {
      // Best-effort beam.
    }
  }
}
