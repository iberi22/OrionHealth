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

abstract class SharingState extends Equatable {
  const SharingState();

  @override
  List<Object?> get props => [];
}

class SharingInitial extends SharingState {}

class SharingReady extends SharingState {}

class SharingScanning extends SharingState {
  final TransferMethod method;
  const SharingScanning(this.method);

  @override
  List<Object?> get props => [method];
}

class SharingAdvertising extends SharingState {
  final TransferMethod method;
  final String nodeId;

  const SharingAdvertising(this.method, this.nodeId);

  @override
  List<Object?> get props => [method, nodeId];
}

class SharingConnecting extends SharingState {
  final TransferMethod method;
  final String deviceId;

  const SharingConnecting(this.method, this.deviceId);

  @override
  List<Object?> get props => [method, deviceId];
}

class SharingConnected extends SharingState {
  final TransferMethod method;
  final String deviceId;

  const SharingConnected(this.method, this.deviceId);

  @override
  List<Object?> get props => [method, deviceId];
}

class SharingTransferring extends SharingState {
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

class SharingComplete extends SharingState {
  final SharingResult result;
  final TransferMethod method;

  const SharingComplete(this.result, this.method);

  @override
  List<Object?> get props => [result, method];
}

class SharingReceiving extends SharingState {
  final SharedHealthPackage? package;
  final TransferMethod method;

  const SharingReceiving({this.package, required this.method});

  @override
  List<Object?> get props => [package, method];
}

class SharingError extends SharingState {
  final String message;
  const SharingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// CUBIT
// ============================================================================

class SharingCubit extends Cubit<SharingState> {
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

  SharingCubit({
    BleSharingService? bleService,
    NfcSharingService? nfcService,
    WifiDirectService? wifiService,
    HealthRecordRepository? healthRecordRepo,
  })  : _bleService = bleService ?? BleSharingService(),
        _nfcService = nfcService ?? NfcSharingService(),
        _wifiService = wifiService ?? WifiDirectService(),
        _healthRecordRepo = healthRecordRepo,
        super(SharingInitial());

  /// Initialize all services
  Future<void> initialize() async {
    await _bleService.initialize();
    await _nfcService.initialize();
    await _wifiService.initialize();

    _setupSubscriptions();

    emit(SharingReady());
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
        emit(SharingScanning(method));
        break;
      case ProtocolEventType.advertising:
        emit(SharingAdvertising(method, event.id ?? ''));
        break;
      case ProtocolEventType.connecting:
        emit(SharingConnecting(method, event.id ?? ''));
        break;
      case ProtocolEventType.connected:
        emit(SharingConnected(method, event.id ?? ''));
        break;
      case ProtocolEventType.transferring:
        emit(SharingTransferring(
          method: method,
          progress: event.progress ?? 0.5,
          message: event.message ?? 'Transferring...',
        ));
        break;
      case ProtocolEventType.completed:
        emit(SharingComplete(
          SharingResult(
            success: true,
            bytesTransferred: event.bytes ?? 0,
            transferTime: event.time ?? Duration.zero,
          ),
          method,
        ));
        break;
      case ProtocolEventType.received:
        emit(SharingReceiving(
          package: event.package as SharedHealthPackage?,
          method: method,
        ));
        break;
      case ProtocolEventType.error:
        emit(SharingError(event.message ?? 'Error'));
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
      emit(const SharingError('Failed to connect'));
      return;
    }

    final result = await _bleService.sendData(package);
    if (result.success) {
      emit(SharingComplete(result, TransferMethod.ble));
    } else {
      emit(SharingError(result.error ?? 'Transfer failed'));
    }
  }

  /// Send via WiFi Direct
  Future<void> sendViaWifi(String targetIp, SharedHealthPackage package) async {
    final result = await _wifiService.sendData(targetIp, package);
    if (result.success) {
      emit(SharingComplete(result, TransferMethod.wifi));
    } else {
      emit(SharingError(result.error ?? 'Transfer failed'));
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

    emit(SharingReady());
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
    emit(SharingReceiving(package: package, method: _currentMethod!));
  }

  /// Accept and import incoming package
  Future<void> acceptIncomingPackage() async {
    final currentState = state;
    if (currentState is SharingReceiving &&
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

    emit(SharingReady());
  }

  /// Reject incoming package
  void rejectIncomingPackage() {
    emit(SharingReady());
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
    emit(SharingReady());
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
