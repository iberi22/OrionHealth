import 'package:equatable/equatable.dart';
import '../../ble_sharing/domain/ble_sharing_service.dart' as ble;
import '../../ble_sharing/infrastructure/nfc_sharing_service.dart' as ble_nfc;
import '../../ble_sharing/infrastructure/wifi_direct_service.dart' as ble_wifi;
import '../infrastructure/ble_sharing_service.dart' as health_ble;
import '../infrastructure/nfc_sharing_service.dart' as nfc;
import '../infrastructure/wifi_direct_service.dart' as wifi;

abstract class ProtocolState extends Equatable {
  final String status;
  final String? message;
  final bool isError;
  final int? bytesTransferred;
  final Duration? transferTime;

  const ProtocolState({
    required this.status,
    this.message,
    this.isError = false,
    this.bytesTransferred,
    this.transferTime,
  });

  @override
  List<Object?> get props => [status, message, isError, bytesTransferred, transferTime];
}

class ProtocolHandler {
  static void handleBleState(ble.BleServiceState state, Function(ProtocolEvent) onEvent) {
    if (state.status == 'scanning') {
      onEvent(ProtocolEvent.scanning);
    } else if (state.status == 'advertising') {
      onEvent(ProtocolEvent.advertising(state.deviceId ?? ''));
    } else if (state.status == 'connecting') {
      onEvent(ProtocolEvent.connecting(state.deviceId ?? ''));
    } else if (state.status == 'connected') {
      onEvent(ProtocolEvent.connected(state.deviceId ?? ''));
    } else if (state.status == 'transferring') {
      onEvent(ProtocolEvent.transferring(0.5, state.message ?? 'Transferring...'));
    } else if (state.status == 'completed') {
      onEvent(ProtocolEvent.completed(
        state.bytesTransferred ?? 0,
        state.transferTime ?? Duration.zero,
      ));
    } else if (state.isError) {
      onEvent(ProtocolEvent.error(state.message ?? 'BLE Error'));
    }
  }

  static void handleHealthBleState(health_ble.BleSharingState state, Function(ProtocolEvent) onEvent) {
    if (state.status == 'scanning') {
      onEvent(ProtocolEvent.scanning);
    } else if (state.status == 'advertising') {
      onEvent(ProtocolEvent.advertising(state.deviceId ?? ''));
    } else if (state.status == 'connecting') {
      onEvent(ProtocolEvent.connecting(state.deviceId ?? ''));
    } else if (state.status == 'connected') {
      onEvent(ProtocolEvent.connected(state.deviceId ?? ''));
    } else if (state.status == 'transferring') {
      onEvent(ProtocolEvent.transferring(0.5, state.message ?? 'Transferring...'));
    } else if (state.status == 'completed') {
      onEvent(ProtocolEvent.completed(
        state.bytesTransferred ?? 0,
        state.transferTime ?? Duration.zero,
      ));
    } else if (state.isError) {
      onEvent(ProtocolEvent.error(state.message ?? 'BLE Error'));
    }
  }

  static void handleNfcState(nfc.NfcSharingState state, Function(ProtocolEvent) onEvent) {
    if (state.status == 'listening') {
      onEvent(ProtocolEvent.scanning);
    } else if (state.status == 'ndef_beam') {
      onEvent(ProtocolEvent.transferring(0.5, state.message ?? 'Beaming...'));
    } else if (state.status == 'received') {
      onEvent(ProtocolEvent.received(state.receivedPackage));
    } else if (state.status == 'completed') {
      onEvent(ProtocolEvent.completed(
        state.bytesTransferred ?? 0,
        state.transferTime ?? Duration.zero,
      ));
    } else if (state.isError) {
      onEvent(ProtocolEvent.error(state.message ?? 'NFC Error'));
    }
  }

  static void handleBleNfcState(ble_nfc.NfcSharingState state, Function(ProtocolEvent) onEvent) {
    if (state.status == 'listening') {
      onEvent(ProtocolEvent.scanning);
    } else if (state.status == 'ndef_beam') {
      onEvent(ProtocolEvent.transferring(0.5, state.message ?? 'Beaming...'));
    } else if (state.status == 'received') {
      onEvent(ProtocolEvent.received(state.receivedPackage));
    } else if (state.status == 'completed') {
      onEvent(ProtocolEvent.completed(
        state.bytesTransferred ?? 0,
        state.transferTime ?? Duration.zero,
      ));
    } else if (state.isError) {
      onEvent(ProtocolEvent.error(state.message ?? 'NFC Error'));
    }
  }

  static void handleWifiState(wifi.WifiSharingState state, Function(ProtocolEvent) onEvent) {
    if (state.status == 'discovering') {
      onEvent(ProtocolEvent.scanning);
    } else if (state.status == 'hosting') {
      onEvent(ProtocolEvent.advertising(state.address ?? ''));
    } else if (state.status == 'connecting') {
      onEvent(ProtocolEvent.connecting(state.address ?? ''));
    } else if (state.status == 'transferring') {
      onEvent(ProtocolEvent.transferring(0.5, state.message ?? 'Transferring...'));
    } else if (state.status == 'received') {
      onEvent(ProtocolEvent.received(state.receivedPackage));
    } else if (state.status == 'completed') {
      onEvent(ProtocolEvent.completed(
        state.bytesTransferred ?? 0,
        state.transferTime ?? Duration.zero,
      ));
    } else if (state.isError) {
      onEvent(ProtocolEvent.error(state.message ?? 'WiFi Error'));
    }
  }

  static void handleBleWifiState(ble_wifi.WifiServiceState state, Function(ProtocolEvent) onEvent) {
    if (state.status == 'discovering') {
      onEvent(ProtocolEvent.scanning);
    } else if (state.status == 'hosting') {
      onEvent(ProtocolEvent.advertising(state.address ?? ''));
    } else if (state.status == 'connecting') {
      onEvent(ProtocolEvent.connecting(state.address ?? ''));
    } else if (state.status == 'transferring') {
      onEvent(ProtocolEvent.transferring(0.5, state.message ?? 'Transferring...'));
    } else if (state.status == 'received') {
      onEvent(ProtocolEvent.received(state.receivedPackage));
    } else if (state.status == 'completed') {
      onEvent(ProtocolEvent.completed(
        state.bytesTransferred ?? 0,
        state.transferTime ?? Duration.zero,
      ));
    } else if (state.isError) {
      onEvent(ProtocolEvent.error(state.message ?? 'WiFi Error'));
    }
  }
}

enum ProtocolEventType {
  scanning,
  advertising,
  connecting,
  connected,
  transferring,
  completed,
  received,
  error,
}

class ProtocolEvent {
  final ProtocolEventType type;
  final String? id;
  final double? progress;
  final String? message;
  final int? bytes;
  final Duration? time;
  final dynamic package;

  ProtocolEvent._({
    required this.type,
    this.id,
    this.progress,
    this.message,
    this.bytes,
    this.time,
    this.package,
  });

  static final ProtocolEvent scanning = ProtocolEvent._(type: ProtocolEventType.scanning);
  factory ProtocolEvent.advertising(String id) => ProtocolEvent._(type: ProtocolEventType.advertising, id: id);
  factory ProtocolEvent.connecting(String id) => ProtocolEvent._(type: ProtocolEventType.connecting, id: id);
  factory ProtocolEvent.connected(String id) => ProtocolEvent._(type: ProtocolEventType.connected, id: id);
  factory ProtocolEvent.transferring(double progress, String message) =>
      ProtocolEvent._(type: ProtocolEventType.transferring, progress: progress, message: message);
  factory ProtocolEvent.completed(int bytes, Duration time) =>
      ProtocolEvent._(type: ProtocolEventType.completed, bytes: bytes, time: time);
  factory ProtocolEvent.received(dynamic package) => ProtocolEvent._(type: ProtocolEventType.received, package: package);
  factory ProtocolEvent.error(String message) => ProtocolEvent._(type: ProtocolEventType.error, message: message);
}
