import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/ble_sharing_service.dart';
import '../infrastructure/nfc_sharing_service.dart';
import '../infrastructure/wifi_direct_service.dart';

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
      _handleBleState(state);
    });

    _nfcSubscription = _nfcService.stateStream.listen((state) {
      _handleNfcState(state);
    });

    _wifiSubscription = _wifiService.stateStream.listen((state) {
      _handleWifiState(state);
    });
  }

  void _handleBleState(BleServiceState state) {
    if (state.status == 'scanning') {
      emit(BleSharingScanning(MedicalTransferMethod.ble));
    } else if (state.status == 'advertising') {
      emit(
        BleSharingAdvertising(MedicalTransferMethod.ble, state.deviceId ?? ''),
      );
    } else if (state.status == 'connecting') {
      emit(
        BleSharingConnecting(MedicalTransferMethod.ble, state.deviceId ?? ''),
      );
    } else if (state.status == 'connected') {
      emit(
        BleSharingConnected(MedicalTransferMethod.ble, state.deviceId ?? ''),
      );
    } else if (state.status == 'transferring') {
      emit(
        BleSharingTransferring(
          method: MedicalTransferMethod.ble,
          progress: 0.5,
          message: state.message ?? 'Transferring...',
        ),
      );
    } else if (state.status == 'completed') {
      emit(
        BleSharingComplete(
          SharingResult(
            success: true,
            bytesTransferred: state.bytesTransferred ?? 0,
            transferTime: state.transferTime ?? Duration.zero,
          ),
          MedicalTransferMethod.ble,
        ),
      );
    } else if (state.isError) {
      emit(BleSharingError(state.message ?? 'BLE Error'));
    }
  }

  void _handleNfcState(NfcSharingState state) {
    if (state.status == 'listening') {
      emit(const BleSharingScanning(MedicalTransferMethod.nfc));
    } else if (state.status == 'ndef_beam') {
      emit(
        BleSharingTransferring(
          method: MedicalTransferMethod.nfc,
          progress: 0.5,
          message: state.message ?? 'Beaming...',
        ),
      );
    } else if (state.status == 'received') {
      emit(
        BleSharingReceiving(
          package: state.receivedPackage,
          method: MedicalTransferMethod.nfc,
        ),
      );
    } else if (state.status == 'completed') {
      emit(
        BleSharingComplete(
          SharingResult(
            success: true,
            bytesTransferred: state.bytesTransferred ?? 0,
            transferTime: state.transferTime ?? Duration.zero,
          ),
          MedicalTransferMethod.nfc,
        ),
      );
    } else if (state.isError) {
      emit(BleSharingError(state.message ?? 'NFC Error'));
    }
  }

  void _handleWifiState(WifiServiceState state) {
    if (state.status == 'discovering') {
      emit(BleSharingScanning(MedicalTransferMethod.wifi));
    } else if (state.status == 'hosting') {
      emit(
        BleSharingAdvertising(MedicalTransferMethod.wifi, state.address ?? ''),
      );
    } else if (state.status == 'connecting') {
      emit(
        BleSharingConnecting(MedicalTransferMethod.wifi, state.address ?? ''),
      );
    } else if (state.status == 'transferring') {
      emit(
        BleSharingTransferring(
          method: MedicalTransferMethod.wifi,
          progress: 0.5,
          message: state.message ?? 'Transferring...',
        ),
      );
    } else if (state.status == 'received') {
      emit(
        BleSharingReceiving(
          package: state.receivedPackage,
          method: MedicalTransferMethod.wifi,
        ),
      );
    } else if (state.status == 'completed') {
      emit(
        BleSharingComplete(
          SharingResult(
            success: true,
            bytesTransferred: state.bytesTransferred ?? 0,
            transferTime: state.transferTime ?? Duration.zero,
          ),
          MedicalTransferMethod.wifi,
        ),
      );
    } else if (state.isError) {
      emit(BleSharingError(state.message ?? 'WiFi Error'));
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
