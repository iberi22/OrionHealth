import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/ble_sharing_service.dart';
import '../infrastructure/nfc_sharing_service.dart';
import '../infrastructure/wifi_direct_service.dart';
import '../../health_sharing/application/protocol_handler.dart';

abstract class BleSharingState extends Equatable {
  const BleSharingState();

  @override
  List<Object?> get props => [];
}

class BleSharingInitial extends BleSharingState {}

class BleSharingReady extends BleSharingState {}

class BleSharingScanning extends BleSharingState {
  final MedicalTransferMethod method;
  const BleSharingScanning(this.method);

  @override
  List<Object?> get props => [method];
}

class BleSharingAdvertising extends BleSharingState {
  final MedicalTransferMethod method;
  final String nodeId;

  const BleSharingAdvertising(this.method, this.nodeId);

  @override
  List<Object?> get props => [method, nodeId];
}

class BleSharingConnecting extends BleSharingState {
  final MedicalTransferMethod method;
  final String deviceId;

  const BleSharingConnecting(this.method, this.deviceId);

  @override
  List<Object?> get props => [method, deviceId];
}

class BleSharingConnected extends BleSharingState {
  final MedicalTransferMethod method;
  final String deviceId;

  const BleSharingConnected(this.method, this.deviceId);

  @override
  List<Object?> get props => [method, deviceId];
}

class BleSharingTransferring extends BleSharingState {
  final MedicalTransferMethod method;
  final double progress;
  final String message;

  const BleSharingTransferring({
    required this.method,
    required this.progress,
    required this.message,
  });

  @override
  List<Object?> get props => [method, progress, message];
}

class BleSharingComplete extends BleSharingState {
  final SharingResult result;
  final MedicalTransferMethod method;

  const BleSharingComplete(this.result, this.method);

  @override
  List<Object?> get props => [result, method];
}

class BleSharingReceiving extends BleSharingState {
  final MedicalSharePackage? package;
  final MedicalTransferMethod method;

  const BleSharingReceiving({this.package, required this.method});

  @override
  List<Object?> get props => [package, method];
}

class BleSharingError extends BleSharingState {
  final String message;
  const BleSharingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BleSharingCubit extends Cubit<BleSharingState> {
  final BleSharingService _bleService;
  final NfcSharingService _nfcService;
  final WifiDirectService _wifiService;

  StreamSubscription? _bleSubscription;
  StreamSubscription? _nfcSubscription;
  StreamSubscription? _wifiSubscription;

  MedicalTransferMethod? _currentMethod;
  // ignore: unused_field
  MedicalSharePackage? _pendingPackage;

  BleSharingCubit({
    BleSharingService? bleService,
    NfcSharingService? nfcService,
    WifiDirectService? wifiService,
  }) : _bleService = bleService ?? BleSharingService(),
       _nfcService = nfcService ?? NfcSharingService(),
       _wifiService = wifiService ?? WifiDirectService(),
       super(BleSharingInitial());

  Future<void> initialize() async {
    await _bleService.initialize();
    await _nfcService.initialize();
    await _wifiService.initialize();

    _setupSubscriptions();
    emit(BleSharingReady());
  }

  void _setupSubscriptions() {
    _bleSubscription = _bleService.stateStream.listen((state) {
      ProtocolHandler.handleBleState(state, (event) => _onProtocolEvent(event, MedicalTransferMethod.ble));
    });

    _nfcSubscription = _nfcService.stateStream.listen((state) {
      ProtocolHandler.handleBleNfcState(state, (event) => _onProtocolEvent(event, MedicalTransferMethod.nfc));
    });

    _wifiSubscription = _wifiService.stateStream.listen((state) {
      ProtocolHandler.handleBleWifiState(state, (event) => _onProtocolEvent(event, MedicalTransferMethod.wifi));
    });
  }

  void _onProtocolEvent(ProtocolEvent event, MedicalTransferMethod method) {
    switch (event.type) {
      case ProtocolEventType.scanning:
        emit(BleSharingScanning(method));
        break;
      case ProtocolEventType.advertising:
        emit(BleSharingAdvertising(method, event.id ?? ''));
        break;
      case ProtocolEventType.connecting:
        emit(BleSharingConnecting(method, event.id ?? ''));
        break;
      case ProtocolEventType.connected:
        emit(BleSharingConnected(method, event.id ?? ''));
        break;
      case ProtocolEventType.transferring:
        emit(BleSharingTransferring(
          method: method,
          progress: event.progress ?? 0.5,
          message: event.message ?? 'Transferring...',
        ));
        break;
      case ProtocolEventType.completed:
        emit(BleSharingComplete(
          SharingResult(
            success: true,
            bytesTransferred: event.bytes ?? 0,
            transferTime: event.time ?? Duration.zero,
          ),
          method,
        ));
        break;
      case ProtocolEventType.received:
        emit(BleSharingReceiving(
          package: event.package as MedicalSharePackage?,
          method: method,
        ));
        break;
      case ProtocolEventType.error:
        emit(BleSharingError(event.message ?? 'Error'));
        break;
    }
  }

  Future<void> startSharing({
    required MedicalTransferMethod method,
    required MedicalSharePackage package,
  }) async {
    _pendingPackage = package;
    _currentMethod = method;

    switch (method) {
      case MedicalTransferMethod.ble:
        await _bleService.startAdvertising(package.recipientNodeId);
        break;
      case MedicalTransferMethod.nfc:
        await _nfcService.shareData(package);
        break;
      case MedicalTransferMethod.wifi:
        await _wifiService.startServer();
        break;
    }
  }

  Future<void> sendViaBle(String deviceId, MedicalSharePackage package) async {
    final connected = await _bleService.connect(deviceId);
    if (!connected) {
      emit(const BleSharingError('Failed to connect'));
      return;
    }

    final result = await _bleService.sendData(package);
    if (result.success) {
      emit(BleSharingComplete(result, MedicalTransferMethod.ble));
    } else {
      emit(BleSharingError(result.error ?? 'Transfer failed'));
    }
  }

  Future<void> sendViaWifi(String targetIp, MedicalSharePackage package) async {
    final result = await _wifiService.sendData(targetIp, package);
    if (result.success) {
      emit(BleSharingComplete(result, MedicalTransferMethod.wifi));
    } else {
      emit(BleSharingError(result.error ?? 'Transfer failed'));
    }
  }

  Future<void> cancelSharing() async {
    await _bleService.disconnect();
    await _bleService.stopAdvertising();
    await _nfcService.stopListening();
    await _wifiService.stop();

    _pendingPackage = null;
    _currentMethod = null;

    emit(BleSharingReady());
  }

  Future<void> startListening(MedicalTransferMethod method) async {
    _currentMethod = method;

    switch (method) {
      case MedicalTransferMethod.ble:
        await _bleService.scanForDevices();
        break;
      case MedicalTransferMethod.nfc:
        await _nfcService.startListening();
        break;
      case MedicalTransferMethod.wifi:
        await _wifiService.startServer();
        break;
    }
  }

  void handleIncomingPackage(MedicalSharePackage package) {
    emit(BleSharingReceiving(package: package, method: _currentMethod!));
  }

  Future<void> acceptIncomingPackage() async {
    emit(BleSharingReady());
  }

  void rejectIncomingPackage() {
    emit(BleSharingReady());
  }

  Future<List<BleDevice>> scanBleDevices() async {
    return await _bleService.scanForDevices();
  }

  Future<List<WifiDirectDevice>> discoverWifiDevices() async {
    return await _wifiService.discoverDevices();
  }

  void reset() {
    emit(BleSharingReady());
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
