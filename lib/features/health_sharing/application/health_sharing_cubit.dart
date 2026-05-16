import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/shared_health_package.dart';
import '../infrastructure/ble_sharing_service.dart';
import '../infrastructure/nfc_sharing_service.dart';
import '../infrastructure/wifi_direct_service.dart';
import '../../health_record/domain/repositories/health_record_repository.dart';
import '../../health_record/domain/entities/medical_record.dart';
import 'protocol_handler.dart';

// ============================================================================
// STATES
// ============================================================================

abstract class HealthSharingState extends Equatable {
  const HealthSharingState();

  @override
  List<Object?> get props => [];
}

class HealthSharingInitial extends HealthSharingState {}

class HealthSharingReady extends HealthSharingState {}

class HealthSharingScanning extends HealthSharingState {
  final TransferMethod method;
  const HealthSharingScanning(this.method);

  @override
  List<Object?> get props => [method];
}

class HealthSharingAdvertising extends HealthSharingState {
  final TransferMethod method;
  final String nodeId;

  const HealthSharingAdvertising(this.method, this.nodeId);

  @override
  List<Object?> get props => [method, nodeId];
}

class HealthSharingConnecting extends HealthSharingState {
  final TransferMethod method;
  final String deviceId;

  const HealthSharingConnecting(this.method, this.deviceId);

  @override
  List<Object?> get props => [method, deviceId];
}

class HealthSharingConnected extends HealthSharingState {
  final TransferMethod method;
  final String deviceId;

  const HealthSharingConnected(this.method, this.deviceId);

  @override
  List<Object?> get props => [method, deviceId];
}

class SharingTransferring extends HealthSharingState {
  final TransferMethod method;
  final double progress;
  final String message;

  const SharingTransferring({
    required this.method,
    required this.progress,
    required this.message,
  });

  @override
  List<Object?> get props => [method, progress, message];
}

class HealthSharingComplete extends HealthSharingState {
  final SharingResult result;
  final TransferMethod method;

  const HealthSharingComplete(this.result, this.method);

  @override
  List<Object?> get props => [result, method];
}

class HealthSharingReceiving extends HealthSharingState {
  final SharedHealthPackage? package;
  final TransferMethod method;

  const HealthSharingReceiving({this.package, required this.method});

  @override
  List<Object?> get props => [package, method];
}

class HealthSharingError extends HealthSharingState {
  final String message;
  const HealthSharingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// CUBIT
// ============================================================================

class HealthSharingCubit extends Cubit<HealthSharingState> {
  final BleSharingService _bleService;
  final NfcSharingService _nfcService;
  final WifiDirectService _wifiService;
  final HealthRecordRepository? _healthRecordRepo;

  StreamSubscription? _bleSubscription;
  StreamSubscription? _nfcSubscription;
  StreamSubscription? _wifiSubscription;

  TransferMethod? _currentMethod;
  // ignore: unused_field
  SharedHealthPackage? _pendingPackage;

  HealthSharingCubit({
    BleSharingService? bleService,
    NfcSharingService? nfcService,
    WifiDirectService? wifiService,
    HealthRecordRepository? healthRecordRepo,
  })  : _bleService = bleService ?? BleSharingService(),
        _nfcService = nfcService ?? NfcSharingService(),
        _wifiService = wifiService ?? WifiDirectService(),
        _healthRecordRepo = healthRecordRepo,
        super(HealthSharingInitial());

  /// Initialize all services
  Future<void> initialize() async {
    await _bleService.initialize();
    await _nfcService.initialize();
    await _wifiService.initialize();

    _setupSubscriptions();

    emit(HealthSharingReady());
  }

  void _setupSubscriptions() {
    _bleSubscription = _bleService.stateStream.listen((state) {
      ProtocolHandler.handleHealthBleState(state, (event) => _onProtocolEvent(event, TransferMethod.ble));
    });

    _nfcSubscription = _nfcService.stateStream.listen((state) {
      ProtocolHandler.handleNfcState(state, (event) => _onProtocolEvent(event, TransferMethod.nfc));
    });

    _wifiSubscription = _wifiService.stateStream.listen((state) {
      ProtocolHandler.handleWifiState(state, (event) => _onProtocolEvent(event, TransferMethod.wifi));
    });
  }

  void _onProtocolEvent(ProtocolEvent event, TransferMethod method) {
    switch (event.type) {
      case ProtocolEventType.scanning:
        emit(HealthSharingScanning(method));
        break;
      case ProtocolEventType.advertising:
        emit(HealthSharingAdvertising(method, event.id ?? ''));
        break;
      case ProtocolEventType.connecting:
        emit(HealthSharingConnecting(method, event.id ?? ''));
        break;
      case ProtocolEventType.connected:
        emit(HealthSharingConnected(method, event.id ?? ''));
        break;
      case ProtocolEventType.transferring:
        emit(SharingTransferring(
          method: method,
          progress: event.progress ?? 0.5,
          message: event.message ?? 'Transferring...',
        ));
        break;
      case ProtocolEventType.completed:
        emit(HealthSharingComplete(
          SharingResult(
            success: true,
            bytesTransferred: event.bytes ?? 0,
            transferTime: event.time ?? Duration.zero,
          ),
          method,
        ));
        break;
      case ProtocolEventType.received:
        emit(HealthSharingReceiving(
          package: event.package as SharedHealthPackage?,
          method: method,
        ));
        break;
      case ProtocolEventType.error:
        emit(HealthSharingError(event.message ?? 'Error'));
        break;
    }
  }

  // ==========================================================================
  // SEND DATA
  // ==========================================================================

  /// Start sharing data via selected method
  Future<void> startSharing({
    required TransferMethod method,
    required SharedHealthPackage package,
  }) async {
    _pendingPackage = package;
    _currentMethod = method;

    switch (method) {
      case TransferMethod.ble:
        await _bleService.startAdvertising(package.recipientNodeId);
        break;
      case TransferMethod.nfc:
        await _nfcService.shareData(package);
        break;
      case TransferMethod.wifi:
        await _wifiService.startServer();
        break;
    }
  }

  /// Send via BLE
  Future<void> sendViaBle(String deviceId, SharedHealthPackage package) async {
    final connected = await _bleService.connect(deviceId);
    if (!connected) {
      emit(const HealthSharingError('Failed to connect'));
      return;
    }

    final result = await _bleService.sendData(package);
    if (result.success) {
      emit(HealthSharingComplete(result, TransferMethod.ble));
    } else {
      emit(HealthSharingError(result.error ?? 'Transfer failed'));
    }
  }

  /// Send via WiFi Direct
  Future<void> sendViaWifi(String targetIp, SharedHealthPackage package) async {
    final result = await _wifiService.sendData(targetIp, package);
    if (result.success) {
      emit(HealthSharingComplete(result, TransferMethod.wifi));
    } else {
      emit(HealthSharingError(result.error ?? 'Transfer failed'));
    }
  }

  /// Cancel current sharing
  Future<void> cancelSharing() async {
    await _bleService.disconnect();
    await _bleService.stopAdvertising();
    await _nfcService.stopListening();
    await _wifiService.stop();

    _pendingPackage = null;
    _currentMethod = null;

    emit(HealthSharingReady());
  }

  // ==========================================================================
  // RECEIVE DATA
  // ==========================================================================

  /// Start listening for incoming data
  Future<void> startListening(TransferMethod method) async {
    _currentMethod = method;

    switch (method) {
      case TransferMethod.ble:
        await _bleService.scanForDevices();
        break;
      case TransferMethod.nfc:
        await _nfcService.startListening();
        break;
      case TransferMethod.wifi:
        await _wifiService.startServer();
        break;
    }
  }

  /// Handle incoming package
  void handleIncomingPackage(SharedHealthPackage package) {
    emit(HealthSharingReceiving(package: package, method: _currentMethod!));
  }

  /// Accept and import incoming package
  Future<void> acceptIncomingPackage() async {
    final currentState = state;
    if (currentState is HealthSharingReceiving &&
        currentState.package != null &&
        _healthRecordRepo != null) {
      final package = currentState.package!;

      // Convert shared package to medical records
      // In a real app, we would decrypt and parse specific categories
      final record = MedicalRecord(
        date: package.createdAt,
        type: RecordType.other,
        summary:
            'Shared Package from ${package.senderNodeId} (${package.metadata.packageType})',
      );

      await _healthRecordRepo.saveRecord(record);
    }

    emit(HealthSharingReady());
  }

  /// Reject incoming package
  void rejectIncomingPackage() {
    emit(HealthSharingReady());
  }

  // ==========================================================================
  // DISCOVERY
  // ==========================================================================

  /// Scan for BLE devices
  Future<List<BleDevice>> scanBleDevices() async {
    return await _bleService.scanForDevices();
  }

  /// Discover WiFi devices
  Future<List<WifiDirectDevice>> discoverWifiDevices() async {
    return await _wifiService.discoverDevices();
  }

  // ==========================================================================
  // UTILITIES
  // ==========================================================================

  /// Reset to ready state
  void reset() {
    emit(HealthSharingReady());
  }

  @override
  Future<void> close() async {
    await _bleSubscription?.cancel();
    await _nfcSubscription?.cancel();
    await _wifiSubscription?.cancel();

    _bleService.dispose();
    _nfcService.dispose();
    _wifiService.dispose();

    return super.close();
  }
}
