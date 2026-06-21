import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:health_wallet/health_wallet.dart' as wallet;
import '../domain/entities/shared_health_package.dart';
import '../infrastructure/ble_sharing_service.dart';
import '../infrastructure/nfc_sharing_service.dart';
import '../infrastructure/wifi_direct_service.dart';
import '../domain/usecases/start_sharing_usecase.dart';
import '../domain/usecases/start_listening_usecase.dart';
import '../domain/usecases/cancel_sharing_usecase.dart';

// ============================================================================
// STATES
// ============================================================================

abstract class SharingState extends Equatable {
  const SharingState();

  @override
  List<Object?> get props => [];
}

class SharingInitial extends SharingState {
  const SharingInitial();
}

class SharingReady extends SharingState {
  const SharingReady();
}

class SharingScanning extends SharingState {
  final TransferMethod method;
  final List<dynamic> devices;

  const SharingScanning(this.method, {this.devices = const []});

  @override
  List<Object?> get props => [method, devices];
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

@injectable
class SharingCubit extends Cubit<SharingState> {
  final BleSharingService _bleService;
  final NfcSharingService _nfcService;
  final WifiDirectService _wifiService;
  final StartSharingUseCase _startSharingUseCase;
  final StartListeningUseCase _startListeningUseCase;
  final CancelSharingUseCase _cancelSharingUseCase;
  final wallet.WalletService _walletService;
  final wallet.EncryptionService _walletEncryption;

  StreamSubscription? _bleSubscription;
  StreamSubscription? _nfcSubscription;
  StreamSubscription? _wifiSubscription;

  TransferMethod? _currentMethod;
  String? _sessionPin;

  SharingCubit({
    BleSharingService? bleService,
    NfcSharingService? nfcService,
    WifiDirectService? wifiService,
    required StartSharingUseCase startSharingUseCase,
    required StartListeningUseCase startListeningUseCase,
    required CancelSharingUseCase cancelSharingUseCase,
    required wallet.WalletService walletService,
    required wallet.EncryptionService walletEncryption,
  })  : _bleService = bleService ?? BleSharingService(),
        _nfcService = nfcService ?? NfcSharingService(),
        _wifiService = wifiService ?? WifiDirectService(),
        _startSharingUseCase = startSharingUseCase,
        _startListeningUseCase = startListeningUseCase,
        _cancelSharingUseCase = cancelSharingUseCase,
        _walletService = walletService,
        _walletEncryption = walletEncryption,
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
      _handleBleState(state);
    });

    _nfcSubscription = _nfcService.stateStream.listen((state) {
      _handleNfcState(state);
    });

    _wifiSubscription = _wifiService.stateStream.listen((state) {
      _handleWifiState(state);
    });
  }

  void _handleBleState(BleSharingState state) {
    if (state.status == 'scanning') {
      emit(const SharingScanning(TransferMethod.ble));
    } else if (state.status == 'advertising') {
      emit(SharingAdvertising(TransferMethod.ble, state.deviceId ?? ''));
    } else if (state.status == 'connecting') {
      emit(SharingConnecting(TransferMethod.ble, state.deviceId ?? ''));
    } else if (state.status == 'connected') {
      emit(SharingConnected(TransferMethod.ble, state.deviceId ?? ''));
    } else if (state.status == 'transferring') {
      emit(SharingTransferring(
        method: TransferMethod.ble,
        progress: 0.5,
        message: state.message ?? 'Transferring...',
      ));
    } else if (state.status == 'completed') {
      emit(SharingComplete(
        SharingResult(
          success: true,
          bytesTransferred: state.bytesTransferred ?? 0,
          transferTime: state.transferTime ?? Duration.zero,
        ),
        TransferMethod.ble,
      ));
    } else if (state.isError) {
      emit(SharingError(state.message ?? 'BLE Error'));
    }
  }

  void _handleNfcState(NfcSharingState state) {
    if (state.status == 'listening') {
      emit(const SharingScanning(TransferMethod.nfc));
    } else if (state.status == 'ndef_beam') {
      emit(SharingTransferring(
        method: TransferMethod.nfc,
        progress: 0.5,
        message: state.message ?? 'Beaming...',
      ));
    } else if (state.status == 'received') {
      emit(SharingReceiving(
        package: state.receivedPackage,
        method: TransferMethod.nfc,
      ));
    } else if (state.status == 'completed') {
      emit(SharingComplete(
        SharingResult(
          success: true,
          bytesTransferred: state.bytesTransferred ?? 0,
          transferTime: state.transferTime ?? Duration.zero,
        ),
        TransferMethod.nfc,
      ));
    } else if (state.isError) {
      emit(SharingError(state.message ?? 'NFC Error'));
    }
  }

  void _handleWifiState(WifiSharingState state) {
    if (state.status == 'discovering') {
      emit(const SharingScanning(TransferMethod.wifi));
    } else if (state.status == 'hosting') {
      emit(SharingAdvertising(TransferMethod.wifi, state.address ?? ''));
    } else if (state.status == 'connecting') {
      emit(SharingConnecting(TransferMethod.wifi, state.address ?? ''));
    } else if (state.status == 'transferring') {
      emit(SharingTransferring(
        method: TransferMethod.wifi,
        progress: 0.5,
        message: state.message ?? 'Transferring...',
      ));
    } else if (state.status == 'received') {
      emit(SharingReceiving(
        package: state.receivedPackage,
        method: TransferMethod.wifi,
      ));
    } else if (state.status == 'completed') {
      emit(SharingComplete(
        SharingResult(
          success: true,
          bytesTransferred: state.bytesTransferred ?? 0,
          transferTime: state.transferTime ?? Duration.zero,
        ),
        TransferMethod.wifi,
      ));
    } else if (state.isError) {
      emit(SharingError(state.message ?? 'WiFi Error'));
    }
  }

  // ==========================================================================
  // SEND DATA
  // ==========================================================================

  /// Start sharing data via selected method
  Future<void> startSharing({
    required TransferMethod method,
    required SharedHealthPackage package,
    String? pin,
  }) async {
    _currentMethod = method;
    _sessionPin = pin;

    if (method == TransferMethod.wifi) {
      // Special case for WiFi: emit Scanning before/during discovery
      emit(const SharingScanning(TransferMethod.wifi));
    }

    await _startSharingUseCase(
      method: method,
      package: package,
      pin: pin,
    );

    if (method == TransferMethod.wifi) {
      final devices = await _wifiService.discoverDevices();
      emit(SharingScanning(TransferMethod.wifi, devices: devices));
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
  Future<void> sendViaWifi(String targetIp, SharedHealthPackage package, {String? pin}) async {
    // If PIN is provided, ensure it's hashed in the package metadata
    SharedHealthPackage packageToSend = package;
    if (pin != null) {
      final pinHash = SharedHealthPackage.hashPin(pin);
      packageToSend = SharedHealthPackage(
        id: package.id,
        senderNodeId: package.senderNodeId,
        recipientNodeId: package.recipientNodeId,
        createdAt: package.createdAt,
        expiresAt: package.expiresAt,
        payload: package.payload,
        metadata: PackageMetadata(
          packageType: package.metadata.packageType,
          consentVerified: package.metadata.consentVerified,
          includedCategories: package.metadata.includedCategories,
          pinHash: pinHash,
          appVersion: package.metadata.appVersion,
        ),
        signature: package.signature,
      );
    }

    final result = await _wifiService.sendData(targetIp, packageToSend);
    if (result.success) {
      emit(SharingComplete(result, TransferMethod.wifi));
    } else {
      emit(SharingError(result.error ?? 'Transfer failed'));
    }
  }

  /// Cancel current sharing
  Future<void> cancelSharing() async {
    await _cancelSharingUseCase();

    _currentMethod = null;

    emit(SharingReady());
  }

  // ==========================================================================
  // RECEIVE DATA
  // ==========================================================================

  /// Start listening for incoming data
  Future<void> startListening(TransferMethod method, {String? pin}) async {
    _currentMethod = method;
    _sessionPin = pin;

    await _startListeningUseCase(method, pin: pin);
  }

  /// Handle incoming package
  void handleIncomingPackage(SharedHealthPackage package) {
    emit(SharingReceiving(package: package, method: _currentMethod!));
  }

  /// Accept and import incoming package
  Future<void> acceptIncomingPackage() async {
    final currentState = state;
    if (currentState is! SharingReceiving || currentState.package == null) {
      return;
    }

    final package = currentState.package!;

    try {
      // 1. Decrypt payload
      Map<String, dynamic> data;
      if (package.metadata.pinHash != null) {
        if (_sessionPin == null) {
          emit(const SharingError('PIN required to decrypt data'));
          return;
        }

        // Re-verify PIN hash
        if (!package.metadata.verifyPin(_sessionPin!)) {
          emit(const SharingError('Invalid PIN'));
          return;
        }

        // Decrypt using wallet encryption service
        final payloadMap = {
          'pinProtected': true,
          'encryptedData': package.payload.encryptedData,
        };
        data = await _walletEncryption.decryptPayload(payloadMap, _sessionPin!);
      } else {
        // Not PIN protected
        final payloadMap = {
          'pinProtected': false,
          'data': jsonDecode(package.payload.encryptedData),
        };
        data = await _walletEncryption.decryptPayload(payloadMap, '');
      }

      // 2. Import into wallet
      await _importDataToWallet(data);

      emit(SharingComplete(
        SharingResult(
          success: true,
          bytesTransferred: package.payload.encryptedData.length,
          transferTime: Duration.zero,
        ),
        _currentMethod ?? TransferMethod.nfc,
      ));
    } catch (e) {
      emit(SharingError('Failed to import data: $e'));
    }
  }

  Future<void> _importDataToWallet(Map<String, dynamic> data) async {
    if (data.containsKey('labs')) {
      for (var item in data['labs']) {
        await _walletService.addLabResult(wallet.LabResult.fromJson(item));
      }
    }
    if (data.containsKey('vitals')) {
      for (var item in data['vitals']) {
        await _walletService.addVitalSign(wallet.VitalSign.fromJson(item));
      }
    }
    if (data.containsKey('medications')) {
      for (var item in data['medications']) {
        await _walletService.addMedication(wallet.MedicationEntry.fromJson(item));
      }
    }
    if (data.containsKey('events')) {
      for (var item in data['events']) {
        await _walletService.addMedicalEvent(wallet.MedicalEvent.fromJson(item));
      }
    }
    if (data.containsKey('concepts')) {
      for (var item in data['concepts']) {
        await _walletService.addMedicalConcept(wallet.MedicalConcept.fromJson(item));
      }
    }
    if (data.containsKey('documents')) {
      for (var item in data['documents']) {
        await _walletService.addDocument(wallet.MedicalDocument.fromJson(item));
      }
    }
    if (data.containsKey('healthRecord')) {
      final hr = data['healthRecord'];
      if (hr is List && hr.isNotEmpty) {
        await _walletService.saveHealthRecord(wallet.HealthRecord.fromJson(hr.first));
      } else if (hr is Map<String, dynamic>) {
        await _walletService.saveHealthRecord(wallet.HealthRecord.fromJson(hr));
      }
    }
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
